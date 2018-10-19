if [[ $# -ne 7 || $1 -eq "-h" ]]; then 
    echo "USAGE: mysql-backup.sh node_user node_host identity_file db_endpoint db_name db_username db_password"
    exit 0
fi

USER=$1   #'ec2-user'
NODE=$2   #34.210.139.3 
IDENTITY_FILE=$3        #./ec2-keypairs/ailabs-couchbase-server-production.pem 
ENDPOINT=$4               #ar1h3jtxk5daznp.cfhpxxd2otwa.us-west-2.rds.amazonaws.com
DB_NAME=$5                #axiom
USERNAME=$6               #production_master
PASSWORD=$7
BACKUP_NAME=mysql-$DB_NAME-$(date +"%Y%m%d%H%M")
ssh $USER@$NODE -i $IDENTITY_FILE -L3307:$ENDPOINT:3306

mysqldump -h127.0.0.1 -P3307 --user=$USERNAME --password=$PASSWORD --database $DB_NAME > $BACKUP_NAME.sql

# Add aws-cli copy to S3 bucket 
