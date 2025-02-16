# install Scoop with  https://github.com/ScoopInstaller/Install 
# ghrepo: https://github.com/ScoopInstaller/Scoop
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

#install packages with scoop