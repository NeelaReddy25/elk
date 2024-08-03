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

yum install java-11-openjdk-devel -y &>>$LOGFILE
VALIDATE $? "Installing java"

cp /home/ec2-user/elk/elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo &>>$LOGFILE
VALIDATE $? "Creating elastic search repo"

yum install elasticsearch -y &>>$LOGFILE
VALIDATE $? "Installing elastic search"

cp /home/ec2-user/elk/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml &>>$LOGFILE
VALIDATE $? "Updating the elastci search yaml file"

systemctl restart elasticsearch &>>$LOGFILE
VALIDATE $? "Restarting elastic search"

systemctl enable elasticsearch &>>$LOGFILE
VALIDATE $? "Enabling elastic search"



