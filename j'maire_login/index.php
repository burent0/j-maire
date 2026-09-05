<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login</title>
  <link rel="stylesheet" href="style.css">
</head>

<body>
  <div class=container>
    <div class="form-box" id="login-form">
        <form action="login" method="get">
          <h2>Login</h2>
          <input name="username" placeholder="Username" type= "text" required />
          <input name="password" placeholder="Password" type="password" required/>
          <button type="submit" name="login" > Login </button>
          <p>Don't have an account? <a href="#">Register here</a></p>
        </form>
    </div>
  </div>
</body>

</html>