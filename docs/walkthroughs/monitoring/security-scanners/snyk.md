Snyk is installed via npm. Run these commands to install it for local use:

npm install -g snyk
Once installed, you need to authenticate with your Snyk account:

snyk auth
To only test your project for known vulnerabilities, browse to your project’s folder and run snyk test:

cd ~/projects/myproj/
snyk test
