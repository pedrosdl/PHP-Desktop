# PHP-Desktop
Develop desktop GUI applications using PHP, HTML5, JavaScript and CSS (Windows only)
![demonstração](https://archive.org/download/php-desktop/PHP-Desktop.gif)
**PowerShell**
```
$url = "https://github.com/pedrosdl/PHP-Desktop/archive/refs/heads/main.zip"
Invoke-WebRequest -Uri $url -OutFile "PHP-Desktop.zip" -UseBasicParsing
Expand-Archive -Path "PHP-Desktop.zip" -DestinationPath "./" -Force
Invoke-Item ".\PHP-Desktop-main"
