<?php
namespace Rcon;
class Rcon
{
	protected $socket;
	protected $socket_head;
	protected $cmd_head;
	protected $response;
	protected $server_host;
	protected $server_port;
	protected $server_pass;
	public function __construct() {}
	public function __destruct()
	{
		$this->logout();
	}
	public function getConnection()
	{
		return $this->socket;
	}
	public function getResponse()
	{
		return $this->response;
	}
	public function connect( array $server_data )
	{
		return $this->createConnection($server_data);
	}
	public function createConnection( array $server_data, $new_instance = false )
	{
		if ($new_instance)
		{
			return (new self($this->site))->connect($server_data);
		}
		else
		{
			$this->server_host = $server_data['host'];
			$this->server_port = $server_data['port'];
			$this->server_pass = $server_data['pass'];
			return $this->login();
		}
	}
	private function get_checksum( $cs )
	{
		sscanf(crc32($cs), "%u", $var);
		$var = dechex($var + 0);
		$x = '0x';
		$a = substr($var, 0, 2);
		$a = $x.$a;
		$b = substr($var, 2, 2);
		$b = $x.$b;
		$c = substr($var, 4, 2);
		$c = $x.$c;
		$d = substr($var, 6, 2);
		$d = $x.$d;
		$return = chr(hexdec($d)) . chr(hexdec($c)) . chr(hexdec($b)) . chr(hexdec($a));
		return $return;
	}
	private function login()
	{
		$passhead           = chr(0xFF) . chr(0x00);
		$this->socket_head  = chr(0x42) . chr(0x45);
		$this->cmd_head     = chr(0xFF) . chr(0x01) . chr(0x00);

		$cmd        = $passhead . $this->server_pass;
		$checksum   = $this->get_checksum($cmd);
		$loginmsg   = $this->socket_head . $checksum . $cmd;
		$this->socket = fsockopen("udp://" . $this->server_host, $this->server_port, $errno, $errstr, 1);
		stream_set_timeout($this->socket, 1);

		if (!$this->socket)
		{
			throw new ConnectionException($errstr, $errno);
		}
		else
		{
			fwrite($this->socket, $loginmsg);
			$response   = fread($this->socket, 16);
			$packet     = $this->splitPacket($response);

			if ($response && isset($packet['data']) && $packet['data'] == chr(0x01))
			{
				return $this;
			}
			else
			{
				throw new AuthenticationException('RCon login unsuccessful.');
			}
		}
	}
	private function logout()
	{
		if ($this->socket)
		{
			$cmd        = "Exit";
			$cmd        = $this->cmd_head . $cmd;
			$checksum   = $this->get_checksum($cmd);
			$cmdmsg     = $this->socket_head . $checksum . $cmd;
			fwrite($this->socket, $cmdmsg);
			fclose($this->socket);
		}
	}
	private function call( $command, $awaitResponse = true )
	{
		$cmd        = $this->cmd_head . $command;
		$checksum   = $this->get_checksum($cmd);
		$cmdmsg     = $this->socket_head . $checksum . $cmd;
		fwrite($this->socket, $cmdmsg);
		if ($awaitResponse)
		{
			$this->read($this->socket);
			return $this->response;
		}
		else
			return true;
	}
	private $max_index;
	private $packet_count = 0;
	private function read( $socket = null )
	{
		$this->max_index    = chr(0x01);
		$this->packet_count = 0;
		$data               = "";
		$temp = $this->realRead($socket);
		while ($temp)
		{
			$packet = $this->splitPacket($temp);
			if (isset($packet['type']) && $packet['type'] == chr(0x01))
			{
				$this->packet_count++;
				$data .= $packet['data'];
				if (isset($payload['index_max']) && $this->max_index != $payload['index_max'])
					$this->max_index = $payload['index_max'];
			}
			$temp = $this->realRead($socket);
		}
		if (chr($this->packet_count) != $this->max_index)
		{
		}
		$this->response = $data;
	}
	private function isPacketOk( $packet )
	{
		if (isset($packet['checksum']) && isset($packet['type']) && isset($packet['payload']) && isset($packet['data']))
		{
			return ($packet['checksum'] == $this->get_checksum(chr(0xFF) . $packet['type'] . $packet['payload'] . $packet['data']));
		}
		else
			return false;
	}
	private function realRead( $socket = null )
	{
		return is_null($socket)
			? fread($this->socket, 102400)
			: fread($socket, 102400);
	}
	public function splitPacket( $data )
	{
		$packet_mask = '/(?<head>BE)(?<checksum>[\x00-\xff]+)\xff(?<type>[\x00|\x01|\x02])(?<data>[[:ascii:]]+)/';
		preg_match($packet_mask, $data, $packet);

		if (isset($packet['type']) && $packet['type'] == chr(0x00))
		{
			$packet_mask = '/(?<payload>)(?<data>[[:ascii:]]+)/';
			preg_match($packet_mask, $packet['data'], $packet_extended);

			$packet['payload']  = $packet_extended['payload'];
			$packet['data']     = $packet_extended['data'];
		}
		elseif (isset($packet['type']) && $packet['type'] == chr(0x01))
		{
			$packet_mask = '/(?<payload>([\x00-\xff]){1})(?<data>[[:ascii:]]+)/';
			preg_match($packet_mask, $packet['data'], $packet_extended);
			if ($packet_extended)
			{
				$packet['payload']  = $packet_extended['payload'];
				$packet['data']     = $packet_extended['data'];
				if ($packet_extended['payload'] == chr(0x00))
				{
					$packet_mask = '/(?<sequence_actual>[\x00-\xff])(?<index_max>[\x00-\xff])(?<index_now>[\x00-\xff])(?<data>[[:ascii:]]+)/';
					preg_match($packet_mask, $packet_extended['data'], $packet_multiple);
					if ($packet_multiple)
					{
						$packet['sub_type']         = chr(0x00);
						$packet['sequence_actual']  = $packet_multiple['sequence_actual'];
						$packet['index_max']        = $packet_multiple['index_max'];
						$packet['index_now']        = $packet_multiple['index_now'];
						$packet['data']             = $packet_multiple['data'];
					}
				}
			}
		}
		elseif (isset($packet['type']) && $packet['type'] == chr(0x02))
		{
			$packet_mask = '/(?<payload>[\x00-\xff]{1})(?<data>[[:ascii:]]+)/';
			preg_match($packet_mask, $packet['data'], $packet_extended);
			$packet['payload']  = $packet_extended['payload'];
			$packet['data']     = $packet_extended['data'];
		}
		if (!$this->isPacketOk($packet))
		{
		}
		return $packet;
	}
	public function sendCommand( $command )
	{
		return $this->call($command);
	}
	public function maxPing( $max_ping )
	{
		return $this->call("maxPing {$max_ping}", false) ? true : false;
	}
	public function version()
	{
		return $this->call("version") ? true : false;
	}
	public function update()
	{
		return $this->call("update") ? true : false;
	}
	public function players()
	{
		$requestData    = $this->call("players");
		$lines          = explode("\n", $requestData);
		$data = array();
		foreach ($lines as $line)
		{
			$packet_mask = '/(?<id>[0-9]+)(\s+)(?<ip>[a-f0-9\.\:]+):(?<port>[0-9]+)(\s+)(?<ping>[0-9]+)(\s+)(?<guid>[a-z0-9]{32})[(](?<state>[a-zA-Z]+)[)](\s+)(?<name>[[:ascii:]]+)*/';
			preg_match($packet_mask, $line, $var);
			if ($var)
			{
				$obj        = new \stdClass();
				$obj->id    = $var['id'];
				$obj->ip    = $var['ip'];
				$obj->port  = $var['port'];
				$obj->ping  = $var['ping']; //  On joining, ping can be '-1' as well
				$obj->guid  = $var['guid']; //  On joining, guid can be '-' as well
				$obj->state = $var['state'];
				if (strpos($var['name'], ' (Lobby)') !== false)
				{
					$obj->name          = substr($var['name'], strlen($var['name']) - 8);
					$obj->is_inLobby    = true;
				}
				else
				{
					$obj->name          = $var['name'];
					$obj->is_inLobby    = false;
				}
				$data[] = $obj;
			}
		}
		return $data;
	}
	public function admins()
	{
		$requestData    = $this->call("admins");
		$lines          = explode("\n", $requestData);
		$data = array();
		foreach ($lines as $line)
		{
			$packet_mask = '/(?<id>[0-9]+)\s(?<ip>[a-f0-9\.\:]+):(?<port>[0-9]+)/';
			preg_match($packet_mask, $line, $var);
			if ($var)
			{
				$obj = new \stdClass();
				$obj->id = $var['id'];
				$obj->ip = $var['ip'];
				$obj->port = $var['port'];
				$data[] = $obj;
			}
		}
		return $data;
	}
	public function kick( $player_id, $reason = "" )
	{
		return $this->call("kick {$player_id} {$reason}") ? true : false;
	}
	public function loadBans()
	{
		return $this->call("loadBans") ? true : false;
	}
	public function writeBans()
	{
		return $this->call("writeBans") ? true : false;
	}
	public function bans()
	{
		$requestData    = $this->call("bans");
		$lines          = explode("\n", $requestData);
		$data = array();
		foreach ($lines as $line)
		{
			$packet_mask = '/(?<id>[0-9]+)\s(?<guid>[a-z0-9]{32})\s(?<duration>[a-z0-9\-]+)\s(?<note>[[:ascii:]]+)/';
			preg_match($packet_mask, $line, $var);
			if ($var)
			{
				$obj = new \stdClass();
				$obj->id = $var['id'];
				$obj->guid = $var['guid'];
				$obj->duration = $var['duration'];
				$obj->note = $var['note'];
				$data[$var['id']] = $obj;
			}
		}
		return $data;
	}
	public function ban( $player_id, $time, $reason = "" )
	{
		if ($time < 0 || !is_int($time))
			return false;
		return $this->call("ban $player_id $time $reason") ? true : false;
	}
	public function addBan( $guid_or_ip, $time, $reason = "" )
	{
		return $this->call("addBan {$guid_or_ip} {$time} {$reason}") ? true : false;
	}
	public function removeBan( $ban_id )
	{
		return $this->call("removeBan $ban_id") ? true : false;
	}
	public function missions()
	{
		$requestData = $this->call("missions");
		return $requestData;
	}
	public function say( $message, $player_id = -1 )
	{
		if ($player_id != -1 && $player_id < 0)
			return false;
		return $this->call("say $player_id $message") ? true : false;
	}
	public function loadScripts()
	{
		return $this->call("loadScripts") ? true : false;
	}
	public function loadEvents()
	{
		return $this->call("loadEvents") ? true : false;
	}
}
class ConnectionException extends \ErrorException {}
class AuthenticationException extends \ErrorException {}
class InvalidStateException extends \ErrorException {}