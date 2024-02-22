<?php
$login_error = $_SESSION['login_error'];

?>

<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login-Site</title>
    <!-- Bootstrap CSS  v4.5.2 -->
    <link href="/public/css/bootstrap.v4.5.2.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="/public/css/index.css" rel="stylesheet">
    <style>
        body {
            background-color: #f4f4f4;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .login-container {
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            background-color: #ffffff;
        }
    </style>
</head>
<body>

    <div class="login-container">
        <h2 class="text-center mb-4">Login Server Control</h2>
        <?php if (isset($login_error)): ?>
            <div class="alert alert-danger">
                <?php echo $login_error; ?>
            </div>
        <?php endif; ?>
        <?php if (isset($_SESSION['message'])): ?>
            <div class="alert alert-success">
                <?php echo $_SESSION['message']; ?>
                <?php unset($_SESSION['message']); ?>
            </div>
        <?php endif; ?>
        <form action="<?php echo $_SESSION["root"]; ?>/login" method="POST">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" class="form-control" id="username" name="username" required>
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" class="form-control" id="password" name="password" required>
            </div>
            <div class="form-group">
                <input type="hidden" name="action" value="login">
                <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
                <button type="submit" class="btn btn-primary btn-block">Login</button>
            </div>
        </form>
    </div>

    <!-- Jquery JS v3.5.1 -->
    <script src="/public/js/jquery-3.5.1.min.js"></script>
    <!-- Bootstrap JS v4.5.2 -->
    <script src="/public/js/bootstrap.bundle.v4.5.2.min.js"></script>
</body>
</html>
