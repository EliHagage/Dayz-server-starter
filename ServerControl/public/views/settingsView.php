<?php

$username = $_SESSION['username'];

?>

<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Server Control Page</title>

    <!-- Bootstrap CSS  v4.5.2 -->
    <link href="/public/css/bootstrap.v4.5.2.min.css" rel="stylesheet">
    <!-- Bootstrap Icons CSS  v1.9.1 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.9.1/font/bootstrap-icons.min.css">
    <!-- Zebra Datepicker -->
    <link href="/public/css/metallic/zebra_datepicker.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="/public/css/index.css" rel="stylesheet">
    <!-- Jquery JS v3.5.1 -->
    <script src="/public/js/jquery-3.5.1.min.js"></script>
    <!-- Bootstrap JS v4.5.2 -->
    <script src="/public/js/bootstrap.bundle.v4.5.2.min.js"></script>
    <!-- Zebra Datepicker JS 3.5.1 -->
    <script src="/public/js/zebra_datepicker.src.js"></script>
</head>
<body  style="background: #00000057;">

    <?php if (isset($_SESSION['errormessages']) && !empty($_SESSION['errormessages'])): ?>
        <div class="toast-container" aria-live="polite" aria-atomic="true">
            <?php foreach ($_SESSION['errormessages'] as $error): ?>
                <div class="toast" role="alert" aria-live="assertive" aria-atomic="true" data-autohide="false">
                    <div class="toast-header">
                        <strong class="mr-auto">Info</strong>
                        <button type="button" class="close" data-dismiss="toast" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="toast-body">
                        <?php echo htmlspecialchars($error); ?>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
        <?php unset($_SESSION['errormessages']); ?>

        <style>
        .toast-container {
          position: fixed;
          top: 1rem;
          right: 1rem;
          z-index: 1050;
        }

        .toast {
          min-width: 350px;
          border-color: #007bff;
        }

        .toast-header {
          background-color: #007bff;
          color: white;
        }
        </style>

        <script type="text/javascript">
            document.addEventListener('DOMContentLoaded', function(event) {
              var toastElList = document.querySelectorAll('.toast');
              for (var i = 0; i < toastElList.length; i++) {
                var toast = new bootstrap.Toast(toastElList[i], {
                  autohide: false
                });
                toast.show();
              }
            });
        </script>

    <?php endif; ?>

    <div class="modal fade" id="passwordChangeModal" tabindex="-1" role="dialog" aria-labelledby="passwordChangeModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="passwordChangeModalLabel">Create a new password</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <form action="<?php echo $_SESSION['root']; ?>/api" method="post">
                        <div class="form-group">
                            <label for="setUsername">New username</label>
                            <input type="text" class="form-control" id="setUsername" name="setUsername" required>
                        </div>
                        <div class="form-group">
                            <label for="setPassword">New password</label>
                            <input type="password" class="form-control" id="setPassword" name="setPassword" required>
                        </div>
                        <div class="form-group">
                            <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
                            <label for="confirmPassword">Confirm password</label>
                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" placeholder="Enter your new password again" required>
                        </div>
                        <input type="hidden" name="action" value="changePassword">
                        <button type="submit" class="btn btn-primary">Change password</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Navigation -->
    <div class="container mt-4">
        <nav class="navbar navbar-expand-lg navbar-light bg-light">
          <a class="navbar-brand" href="<?php echo $_SESSION['root']; ?>">Home</a>
          <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
          </button>
          <div class="collapse navbar-collapse" id="navbarNav">
            <!-- Link-List -->
            <ul class="navbar-nav">

                <li class="nav-item">
                    <a class="nav-link" href="<?php echo $_SESSION['root']; ?>/settings">Settings</a>
                </li>

                <li class="nav-item">
                    <a class="nav-link" href="<?php echo $_SESSION['root']; ?>/modinfos">Mod Infos</a>
                </li>

                <li class="nav-item">
                    <a class="nav-link" href="<?php echo $_SESSION['root']; ?>/editfiles">Edit Files</a>
                </li>

                <li class="nav-item">
                    <a class="nav-link" href="#" onclick="updateServerWithOption()">Update Server</a>
                </li>

                <script>
                function startServerWithOption() {
                    var startHidden = confirm("Should the server be started with a hidden window?");
                    var baseUrl = "<?php echo $_SESSION['root']; ?>/api?action=start-server";
                    var urlWithOption = baseUrl + "&hidden=" + (startHidden ? "true" : "false");
                    window.location.href = urlWithOption;
                }

                function updateServerWithOption() {
                    var updateHidden = confirm("Should the update be carried out with a hidden window?");
                    var baseUrl = "<?php echo $_SESSION['root']; ?>/api?action=update-server";
                    var urlWithOption = baseUrl + "&hidden=" + (updateHidden ? "true" : "false");
                    window.location.href = urlWithOption;
                }
                </script>
                
            </ul>

            <ul class="navbar-nav ml-auto">
              <li class="nav-item dropdown">
                  <a class="nav-link dropdown-toggle" href="#" id="navbarDropdownMenuLink" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                      Logged in as <?php echo htmlspecialchars($username); ?>
                  </a>
                  <div class="dropdown-menu" aria-labelledby="navbarDropdownMenuLink">
                    <a class="dropdown-item" href="#" data-toggle="modal" data-target="#passwordChangeModal">Change password</a>
                    <a class="dropdown-item" href="<?php echo $_SESSION['root']; ?>/logout">Logout</a>
                  </div>
              </li>
            </ul>
          </div>
        </nav>
    </div>

  <?php if (!empty($_SESSION['messages'])): ?>
      <div class="alert alert-info alert-dismissible fade show" role="alert">
          <?php foreach ($_SESSION['messages'] as $message): ?>
              <span><?php echo htmlspecialchars($message); ?></span><br>
          <?php endforeach; ?>
          <button type="button" class="close" data-dismiss="alert" aria-label="Close">
              <span aria-hidden="true">&times;</span>
          </button>
      </div>
      <?php unset($_SESSION['messages']); ?>
  <?php endif; ?>



<!-- Settings subordinate navigation bar -->
<?php if (!empty($settings)): ?>
    <div class="container mt-4">
        <nav class="navbar navbar-expand-lg navbar-light bg-secondary">
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#subNav" aria-controls="subNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="subNav">
                <ul class="navbar-nav">
                    <?php foreach ($settings as $key => $value): ?>
                        <li class="nav-item">
                            <a class="nav-link text-white" href="#<?php echo htmlspecialchars($key); ?>"><?php echo htmlspecialchars($key); ?></a>
                        </li>
                    <?php endforeach; ?>
                </ul>
            </div>
        </nav>
    </div>
<?php endif; ?>

<?php foreach ($settings as $key => $section): ?>
    
    <?php if ($key === "ScriptConfig"): ?>
        <div class="container mt-4">
            <div id="<?php echo htmlspecialchars($key); ?>">
                <h2><?php echo htmlspecialchars($key); ?> Settings</h2>
                <?php foreach ($section as $index => $config): ?>
                    <form action="<?php echo $_SESSION['root']; ?>/settings" method="post">
                        <input type="hidden" name="csrf_token" value="<?php echo htmlspecialchars($_SESSION['csrf_token']); ?>">
                        <input type="hidden" name="config_index" value="<?php echo htmlspecialchars($index); ?>">
                        <input type="hidden" name="action" value="updateServerConfig">
                        <div class="table-responsive">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>Field name</th>
                                        <th>Value</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php foreach ($config as $fieldKey => $fieldValue): ?>
                                        <tr>
                                            <td><?php echo htmlspecialchars($fieldKey); ?></td>
                                            <td>
                                                <input type="text" name="config[<?php echo htmlspecialchars($fieldKey); ?>]" value="<?php echo htmlspecialchars($fieldValue); ?>" class="form-control"/>
                                            </td>
                                        </tr>
                                    <?php endforeach; ?>
                                </tbody>
                            </table>
                        </div>
                        <button type="submit" class="btn btn-primary">Save changes</button>
                    </form>
                    <hr>
                <?php endforeach; ?>
            </div>
        </div>
    <?php endif; ?>

    <?php if ($key === "ServerConfigurations"): ?>
        <div class="container mt-4">
            <div id="<?php echo htmlspecialchars($key); ?>">
                <h2><?php echo htmlspecialchars($key); ?> Settings</h2>


                <form class="mt-2" action="<?php echo $_SESSION['root']; ?>/settings" method="post">
                    <input type="hidden" name="csrf_token" value="<?php echo htmlspecialchars($_SESSION['csrf_token']); ?>">
                    <input type="hidden" name="action" value="addNewServer">
                    <button type="submit" class="btn btn-sm btn-warning mt-2">Add new Server</button>
                </form>

                <form class="mt-2" action="<?php echo $_SESSION['root']; ?>/settings" method="GET">
                    <input type="hidden" name="csrf_token" value="<?php echo htmlspecialchars($_SESSION['csrf_token']); ?>">
                    <div class="form-group">
                        <label for="serverIndex">Select Server:</label>
                        <select name="serverIndex" id="serverIndex" class="form-control" onchange="this.form.submit()">
                            <option value="">Choose a server...</option>
                            <?php foreach ($section as $index => $serverConfig): ?>
                                <option value="<?php echo htmlspecialchars($index); ?>" <?php if (isset($_GET['serverIndex']) && $_GET['serverIndex'] == $index) echo 'selected'; ?>>
                                    <?php echo htmlspecialchars($serverConfig['Name'] . " - " . $serverConfig['Serverip'] . ":" . $serverConfig['GamePort']); ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                </form>
            </div>
        </div>
    <?php endif; ?>

    <?php if ($key === "ServerConfigurations" && isset($_GET['serverIndex']) && $_GET['serverIndex'] !== ''): ?>
        <?php $selectedServer = $section[$_GET['serverIndex']]; ?>
        <div class="container mt-4">
            <div id="<?php echo htmlspecialchars($key); ?>">
                <h2><?php echo htmlspecialchars($key); ?> Settings</h2>
                <form action="<?php echo $_SESSION['root']; ?>/settings/" method="POST">
                    <input type="hidden" name="csrf_token" value="<?php echo htmlspecialchars($_SESSION['csrf_token']); ?>">
                    <input type="hidden" name="serverIndex" value="<?php echo htmlspecialchars($_GET['serverIndex']); ?>">
                    <input type="hidden" name="action" value="updateServerConfigurations">
                    <div class="table-responsive">
                        <table class="table">
                            <tbody>
                                <tr>
                                    <th>Startserver:</th>
                                    <td>
                                        <input type="hidden" name="Startserver" value="false">
                                        <input class="form-check custom-checkbox" type="checkbox" name="Startserver" value="true" <?php echo $selectedServer['Startserver'] ? 'checked' : ''; ?> class="form-check-input">
                                    </td>
                                </tr>
                                <tr>
                                    <th>Name:</th>
                                    <td><input type="text" name="Name" value="<?php echo htmlspecialchars($selectedServer['Name']); ?>" class="form-control"></td>
                                </tr>
                                <tr>
                                    <th>Mapfolder:</th>
                                    <td><input type="text" name="Mapfolder" value="<?php echo htmlspecialchars($selectedServer['Mapfolder']); ?>" class="form-control"></td>
                                </tr>
                                <tr>
                                    <th>Server IP:</th>
                                    <td><input type="text" name="Serverip" value="<?php echo htmlspecialchars($selectedServer['Serverip']); ?>" class="form-control"></td>
                                </tr>
                                <tr>
                                    <th>RCON Port:</th>
                                    <td><input type="text" name="rconport" value="<?php echo htmlspecialchars($selectedServer['rconport']); ?>" class="form-control"></td>
                                </tr>
                                <tr>
                                    <th>Steam Query Port:</th>
                                    <td><input type="text" name="steamQueryPort" value="<?php echo htmlspecialchars($selectedServer['steamQueryPort']); ?>" class="form-control"></td>
                                </tr>
                                <tr>
                                    <th>RCON Password:</th>
                                    <td><input type="text" name="rconpassword" value="<?php echo htmlspecialchars($selectedServer['rconpassword']); ?>" class="form-control"></td>
                                </tr>
                                <tr>
                                    <th>Server Restart:</th>
                                    <td><input type="text" name="Server_restart" value="<?php echo htmlspecialchars($selectedServer['Server_restart']); ?>" class="form-control"></td>
                                </tr>
                                <tr>
                                    <th>Game Port:</th>
                                    <td><input type="text" name="GamePort" value="<?php echo htmlspecialchars($selectedServer['GamePort']); ?>" class="form-control"></td>
                                </tr>
                                <tr>
                                    <th>Server CPU:</th>
                                    <td><input type="text" name="serverCPU" value="<?php echo htmlspecialchars($selectedServer['serverCPU']); ?>" class="form-control"></td>
                                </tr>
                                <tr>
                                    <th>Args:</th>
                                    <td>
                                        <div id="args-container">
                                            <?php foreach ($selectedServer['Args'] as $argIndex => $argValue): ?>
                                                <div class="input-group mb-2">
                                                    <?php
                                                    $isModArg = strpos($argValue, '-mod=') === 0;
                                                    $isArgWithDash = strpos($argValue, '-') === 0;
                                                    $readonly = $isModArg ? 'readonly' : '';
                                                    if (!$isModArg) {
                                                        if ($selectedServer['Startserver'] && $isArgWithDash) {
                                                            $readonly = '';
                                                        } elseif ($selectedServer['Startserver'] && !$isArgWithDash) {
                                                            $readonly = 'readonly';
                                                        } elseif (!$selectedServer['Startserver'] && $isArgWithDash) {
                                                            $readonly = '';
                                                        } elseif (!$selectedServer['Startserver'] && !$isArgWithDash) {
                                                            $readonly = '';
                                                        }
                                                    }
                                                    ?>
                                                    <input type="text" 
                                                           name="Args[<?php echo $argIndex; ?>]" 
                                                           value="<?php echo htmlspecialchars($argValue); ?>" 
                                                           class="form-control"
                                                           <?php echo $readonly; ?>>
                                                    <?php if (!$readonly): ?>
                                                        <div class="input-group-append">
                                                            <button class="btn btn-outline-secondary remove-arg" type="button">-</button>
                                                        </div>
                                                    <?php endif; ?>
                                                </div>
                                            <?php endforeach; ?>
                                        </div>
                                        <button type="button" id="add-arg" class="btn btn-secondary">+ Add Arg</button>
                                    </td>
                                </tr>


                            </tbody>
                        </table>
                    </div>
                    <button type="submit" class="btn btn-primary">Save Changes</button>
                    <button type="submit" name="action" value="deleteServerConfigurations" class="btn btn-danger" onclick="return confirm('Are you sure you want to delete this server?');">Delete Server</button>
                </form>
            </div>
        </div>
    <?php endif; ?>


    <?php if ($key === "ModInfo" && isset($_GET['serverIndex']) && $_GET['serverIndex'] !== ''): ?>
        <div class="container mt-4">
            <div id="<?php echo htmlspecialchars($key); ?>">
                <h2><?php echo htmlspecialchars($key); ?> Settings</h2>
                <div class="table-responsive">
                    <table class="table table-sm table-hover table-striped">
                        <thead class="thead-dark">
                            <tr>
                                <th>Mod Name</th>
                                <th>Mod ID</th>
                                <th>Active</th>
                                
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($section as $index => $modInfo): ?>

                                <tr>
                                    <form action="<?php echo $_SESSION['root']; ?>/settings" method="post">
                                        <td>
                                            <a href="https://steamcommunity.com/sharedfiles/filedetails/?id=<?php echo isset($modInfo['Mod_ID']) ? htmlspecialchars($modInfo['Mod_ID']) : 'Unknown Mod ID'; ?>" target="_blank" /><?php echo isset($modInfo['Mod_Name']) ? htmlspecialchars($modInfo['Mod_Name']) : 'Unknown Mod ID'; ?>
                                        </td>
                                        <td><?php echo isset($modInfo['Mod_ID']) ? htmlspecialchars($modInfo['Mod_ID']) : 'Unknown Mod ID'; ?></td>
                                        <td>
                                            <input type="hidden" name="csrf_token" value="<?php echo htmlspecialchars($_SESSION['csrf_token']); ?>">
                                            <input type="hidden" name="config_index" value="<?php echo htmlspecialchars($index); ?>">
                                            <input type="hidden" name="serverIndex" value="<?php echo $_GET['serverIndex']; ?>">
                                            <input type="hidden" name="action" value="updateModInfo">
                                            <input type="checkbox" name="modInfo[activeServers][]" value="<?php echo $_GET['serverIndex']; ?>"
                                            <?php echo in_array($_GET['serverIndex'], $modInfo['activeServers'] ?? []) ? 'checked' : ''; ?>
                                            class="form-check-input"/>
                                        </td>
                                        
                                    </form>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    <?php endif; ?>


<?php endforeach; ?>


<script type="text/javascript">
    function saveSelectedServerIndex() {
        var selectedIndex = document.getElementById('selectedServer').value;
        document.getElementById('selectedServerIndex').value = selectedIndex;
    }

    function setScrollPositionCookie(scrollPosition) {
        document.cookie = "scrollPosition=" + scrollPosition + ";path=/";
    }

    function deleteCookie(name) {
        document.cookie = name + '=; Path=/; Expires=Thu, 01 Jan 1970 00:00:01 GMT;';
    }

    function getCookie(name) {
        var decodedCookie = decodeURIComponent(document.cookie);
        var ca = decodedCookie.split(';');
        for(var i = 0; i < ca.length; i++) {
            var c = ca[i].trim();
            if (c.indexOf(name + "=") == 0) {
                return c.substring(name.length + 1, c.length);
            }
        }
        return "";
    }

    document.addEventListener('DOMContentLoaded', function(event) {
        var savedScrollPos = getCookie('scrollPosition');

        if (savedScrollPos) {
            window.scrollTo(0, savedScrollPos);
        }

        var selectElements = document.querySelectorAll('select');
        selectElements.forEach(function(select) {
            select.addEventListener('change', function() {
                setScrollPositionCookie(window.scrollY);
                this.form.submit();
            });
        });

        var inputElements = document.querySelectorAll('input[type="text"]');
        for (var i = 0; i < inputElements.length; i++) {
            inputElements[i].addEventListener('keyup', function(e) {
                if (e.keyCode === 13) {
                    setScrollPositionCookie(window.scrollY);
                    this.form.submit();
                }
            });
        }

        document.querySelectorAll('input[type="checkbox"]').forEach(function(checkbox) {
            checkbox.addEventListener('change', function() {
                setScrollPositionCookie(window.scrollY);
                this.form.submit();
            });
        });

        if (savedScrollPos) {
            deleteCookie('scrollPosition');
        }

        document.getElementById('add-arg').addEventListener('click', function() {
            var newArgIndex = document.querySelectorAll('#args-container .input-group').length;
            var newInputGroup = document.createElement('div');
            newInputGroup.classList.add('input-group', 'mb-2');
            newInputGroup.innerHTML = `<input type="text" name="Args[${newArgIndex}]" value="" class="form-control">` +
                                      `<div class="input-group-append">` +
                                      `<button class="btn btn-outline-secondary remove-arg" type="button">-</button>` +
                                      `</div>`;
            document.getElementById('args-container').appendChild(newInputGroup);
        });

        document.getElementById('args-container').addEventListener('click', function(e) {
            if (e.target.classList.contains('remove-arg')) {
                e.target.closest('.input-group').remove();
            }
        });
    });
</script>


<a href="#" id="back-to-top" title="back to top">
    <i class="bi bi-arrow-up-circle-fill"></i>
</a>
<style type="text/css">
    #back-to-top {
        position: fixed;
        bottom: 20px;
        right: 20px;
        cursor: pointer;
        font-size: 2rem;
    }
</style>
<script>
    document.getElementById('back-to-top').addEventListener('click', function(e){
        e.preventDefault();
        window.scrollTo({ top: 0, behavior: 'smooth' });
    });
</script>
</body>
</html>
