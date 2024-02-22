<?php

$username = $_SESSION['username']

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
<body>

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
                    <a class="nav-link" href="<?php echo $_SESSION['root']; ?>/api?action=start-server">Start Server</a>
                </li>

                <li class="nav-item">
                    <a class="nav-link" href="<?php echo $_SESSION['root']; ?>/api?action=update-server">Update Server</a>
                </li>
                
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

    <div class="container mt-4">
        <div class="text-white">Links:</div>
        <ul>
            <li><a class="text-white" target="_blank" href="http://office.liztechdata.com">XML File Tester And Trader And Trader+ Test you files here</a></li>
            <li><a class="text-white" target="_blank" href="https://office.liztechdata.com">Admin Console Website Admin Your Server From The WebSite</a></li>
            <li><a class="text-white" target="_blank" href="https://discord.gg/hbSDeTR7w5">Join our Discord for more help</a></li>
			<li><a class="text-white" target="_blank" href="https://www.paypal.com/paypalme/Elihagage">Get US coffe or Support us</a></li>
        </ul>
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
