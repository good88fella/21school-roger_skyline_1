#!/bin/bash

if [[ $# -ne 2 ]]; then
  echo "Usage: ./autodeploy.sh [user of the VM toconnect to] [SSH port of the VM]";
  exit
fi

if [[ -d $1 ]]; then
  echo "$1 already exists"
  exit
fi

deploy="deploy.sh"
echo '#!/bin/bash' > $deploy
echo "cd /home/$1" >> $deploy
echo "if [[ -d website ]]; then" >> $deploy
echo "rm -Rf website" >> $deploy
echo "fi" >> $deploy
echo "mkdir website && cd website" >> $deploy
echo "mkdir site.git && cd site.git" >> $deploy
echo "git init --bare" >> $deploy
echo "cd hooks" >> $deploy
echo "echo '#!/bin/bash' > post-receive" >> $deploy
echo "echo 'git --work-tree=/var/www/html --git-dir=/home/$1/website/site.git checkout -f' >> post-receive" >> $deploy
echo "chmod +x post-receive" >> $deploy
chmod +x $deploy
ssh $1@localhost -p $2 'bash -s' < deploy.sh
rm -Rf deploy.sh

mkdir $1 && cd $1
scp -P $2 -r $1@localhost:/var/www/html/Login ./
git init
git remote add website_repo ssh://$1@localhost:$2/home/$1/website/site.git

update="update.sh"
echo '#!/bin/bash' > $update
echo 'if [[ $# -ne 1 ]]; then' >> $update
echo -n 'echo "Usage: ./' >> $update
echo -n $update >> $update
echo ' [git commit comments]"' >> $update
echo 'exit' >> $update
echo 'fi' >> $update
echo 'git add .' >> $update
echo 'git commit -m "$1"' >> $update
echo 'git push website_repo master' >> $update
chmod +x $update
echo 'exit' >> $update
echo '*.sh' > .gitignore
echo '.gitignore' >> .gitignore
bash update.sh "init"
exit
