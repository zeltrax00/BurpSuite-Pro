# Name is Important
write-host " ZZZZZZZZZZ  EEEEEEEEEE  LLL       TTTTTTTTTTT  RRRRRRR            AAA        XXX   XXX " -foregroundcolor "Red"
write-host "      ZZZZ   EEE         LLL           TTT      RRR   RRR         AAAAA        XXX XXX  " -foregroundcolor "Red"
write-host "     ZZZZ    EEE         LLL           TTT      RRR   RRR        AA  AAA        XXXXX   " -foregroundcolor "cyan"
write-host "    ZZZZ     EEEEEEEEEE  LLL           TTT      RRRRRRRR        AA    AAA        XXX    " -foregroundcolor "cyan"
write-host "   ZZZZ      EEE         LLL           TTT      RRR   RRR      AAAAAAAAAAA      XXXXX   " -foregroundcolor "cyan"
write-host "  ZZZZ       EEE         LLL           TTT      RRR    RRR    AA        AAA    XXX XXX  " -foregroundcolor "green"
write-host " ZZZZZZZZZZ  EEEEEEEEEE  LLLLLLLLLL    TTT      RRR     RRR  AA          AAA  XXX   XXX " -foregroundcolor "green"


# Set Wget Progress to Silent, Becuase it slows down Downloading by 50x
echo "Setting Wget Progress to Silent, Becuase it slows down Downloading by 50x`n"
$ProgressPreference = 'SilentlyContinue'

# Downloading Burp Suite Professional
if (Test-Path burpsuite_pro.jar){
    echo "Burp Suite Professional JAR file is available.`nChecking its Integrity ...."
    if (((Get-Item burpsuite_pro_v*.jar).length/1MB) -lt 500 ){
        echo "`n`t`tFiles Seems to be corrupted `n`t`tDownloading Latest Burp Suite Professional ...."
		$version = (Invoke-WebRequest -Uri "https://portswigger.net/burp/releases/community/latest" -UseBasicParsing).Links.href | Select-String -Pattern "product=pro&amp;version=*" | Select-Object -First 1 | ForEach-Object { [regex]::Match($_, '\d+\.\d+\.\d+').Value }
		wget "https://portswigger-cdn.net/burp/releases/download?product=pro&version=&type=jar" -O "burpsuite_pro_$version.jar"
        echo "`nBurp Suite Professional is Downloaded.`n"
    }else {echo "File Looks fine. Lets proceed for Execution"}
}else {
    echo "`n`t`tDownloading Latest Burp Suite Professional ...."
	$version = (Invoke-WebRequest -Uri "https://portswigger.net/burp/releases/community/latest" -UseBasicParsing).Links.href | Select-String -Pattern "product=pro&amp;version=*" | Select-Object -First 1 | ForEach-Object { [regex]::Match($_, '\d+\.\d+\.\d+').Value }
	wget "https://portswigger-cdn.net/burp/releases/download?product=pro&version=&type=jar" -O "burpsuite_pro_$version.jar"
    echo "`nBurp Suite Professional is Downloaded.`n"
}

# Creating Shortcut
$Desktop = $DesktopPath = [Environment]::GetFolderPath("Desktop")
if (Test-Path "$Desktop\BurpSuite Pro.lnk") {rm "$Desktop\BurpSuite Pro.lnk"}
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$Desktop\BurpSuite Pro.lnk")
$Shortcut.TargetPath = "C:\Program Files\Common Files\Oracle\Java\javapath\javaw.exe"
$Shortcut.Arguments = "--add-opens=java.desktop/javax.swing=ALL-UNNAMED--add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED -javaagent:`"$PSScriptRoot\loader.jar`" -noverify -jar `"$PSScriptRoot\burpsuite_pro_$version.jar`""
$Shortcut.IconLocation = "$PSScriptRoot\burpsuite_pro.ico"
$Shortcut.Save()


# Lets Activate Burp Suite Professional with keygenerator and Keyloader
echo "Reloading Environment Variables ...."
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
echo "`n`nStarting Keygenerator ...."
start-process javaw.exe -argumentlist "-jar loader.jar"
echo "`n`nStarting Burp Suite Professional"
javaw --add-opens=java.desktop/javax.swing=ALL-UNNAMED--add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.tree=ALL-UNNAMED --add-opens=java.base/jdk.internal.org.objectweb.asm.Opcodes=ALL-UNNAMED -javaagent:"loader.jar" -noverify -jar "burpsuite_pro_$version.jar"
