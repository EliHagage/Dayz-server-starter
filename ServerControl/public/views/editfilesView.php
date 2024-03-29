<?php

$username = $_SESSION['username'];


$loadedFiles = [
    'settings' => 'Settings',
    'adminlist' => 'Admin List',
    'jokes' => 'Jokes',
    'servermsg' => 'Server Message',
    'messagematches' => 'Message Matches'
];

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
                    <a id="startServerBtn" class="nav-link" href="#">Start Server</a>
                </li>

                <li class="nav-item">
                    <a id="upddateServerBtn" class="nav-link" href="#">Update Server</a>
                </li>

                <script>
                    $(document).ready(function() {
                        function startServerWithOption(event) {
                            event.preventDefault();
                            var startHidden = confirm("Should the server be started with a hidden window?");
                            var baseUrl = "<?php echo $_SESSION['root']; ?>/api?action=start-server";
                            var urlWithOption = baseUrl + "&hidden=" + (startHidden ? "true" : "false");
                            
                            $.ajax({
                                url: urlWithOption,
                                type: "GET", 
                                success: function(data) {
                                    console.log("Server started:", data);
                                },
                                error: function(error) {
                                    console.error("Error starting server:", error);
                                }
                            });
                        }

                        function updateServerWithOption(event) {
                            event.preventDefault();
                            var updateHidden = confirm("Should the update be carried out with a hidden window?");
                            var baseUrl = "<?php echo $_SESSION['root']; ?>/api?action=update-server";
                            var urlWithOption = baseUrl + "&hidden=" + (updateHidden ? "true" : "false");
                            
                            $.ajax({
                                url: urlWithOption,
                                type: "GET",
                                success: function(data) {
                                    console.log("Server updated:", data);
                                },
                                error: function(error) {
                                    console.error("Error updating server:", error);
                                }
                            });
                        }

                        $("#startServerBtn").click(startServerWithOption);
                        $("#upddateServerBtn").click(updateServerWithOption);
                    });
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
<div class="container mt-4">
    <nav class="navbar navbar-expand-lg navbar-light bg-secondary">
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#subNav" aria-controls="subNav" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="subNav">
            <ul class="navbar-nav">
                <?php foreach ($loadedFiles as $fileKey => $fileName): ?>
                    <li class="nav-item">
                        <a class="nav-link text-white" href="#<?php echo htmlspecialchars($fileKey); ?>"><?php echo htmlspecialchars($fileName); ?></a>
                    </li>
                <?php endforeach; ?>
            </ul>
        </div>
    </nav>
</div>

<?php foreach ($loadedFiles as $fileKey => $fileName): ?>
    <div class="container mt-4" id="<?php echo htmlspecialchars($fileKey); ?>">
        <h2><?php echo htmlspecialchars($fileName); ?></h2>
        <form action="<?php echo $_SESSION['root']; ?>/editfiles" method="post">
            <input type="hidden" name="csrf_token" value="<?php echo htmlspecialchars($_SESSION['csrf_token']); ?>">
            <?php if ($fileKey === 'settings' && isset($settings) && is_array($settings)): ?>
                <textarea name="settingsContent" rows="20" class="form-control"><?php
                    echo htmlspecialchars(json_encode($settings, JSON_PRETTY_PRINT));
                ?></textarea>
            <?php else: ?>
                <textarea name="<?php echo htmlspecialchars($fileKey); ?>Content" rows="20" class="form-control"><?php
                    echo htmlspecialchars(${$fileKey});
                ?></textarea>
            <?php endif; ?>
            <button type="submit" class="btn btn-primary mt-2">Save Changes</button>
        </form>
    </div>
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
