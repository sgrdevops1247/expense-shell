#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log 
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
   if [ $1 -ne 0 ]
   then
     echo -e "$2...$R FAILURE $N"
     exit 1
   else
     echo -e "$2...$G SUCCESS $N"
   fi
}

if [ $USERID -ne 0 ]
then 
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else 
    echo "You are super user."
fi

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installing ngnix"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabling Engnix"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting Engnix"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Removing existing content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading front end code"

cd /usr/share/nginx/html &>>$LOGFILE
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "Extracting Frontend code"

#check your repo and path
cp /home/ec2-user/expense-shell/expense.conf /etc/ngnix/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "copied expense conf"

systemctl restart ngnix &>>$LOGFILE
VALIDATE $? "Restarting ngnix"



