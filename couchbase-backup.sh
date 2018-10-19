# USAGE identity_file couchbase-backup.sh backup_directory backup_name backup_bucket_name couchbase_username couchbase_password s3_bucket_name
if [[ $# -ne 7 || $1 -eq "-h" ]]; then
    echo "USAGE: identity_file couchbase-backup.sh backup_directory backup_name backup_bucket_name couchbase_username couchbase_password"
    echo "Requires that the following packages be installed and on the path\n\tcbbackup\n\taws-cli"
    exit 0
fi

COUCHBASE_HOME=/opt/couchbase/bin
IDENTITY_FILE=$1   #ec2-keypairs/ailabs-cluster-node-qa.pem 
BACKUP_DIR=$2   #/tmp/cbbackup
BACKUP_NAME=$3-$(date +"%Y%m%d%H%M")
BACKUP_BUCKET_NAME=$4  #axiom
USERNAME=$5
PASSWORD=$6
S3_BUCKET_NAME=$7
mkdir -p $BACKUP_DIR
# Open an SSH tunnel 
ssh -f -o ExitOnForwardFailure=yes ec2-user@34.217.41.118 -i ec2-keypairs/ailabs-cluster-node-qa.pem -L8191:10.0.10.7:8091 sleep 10
$COUCHBASE_HOME/cbbackup --bucket-source=$BACKUP_BUCKET_NAME http://localhost:8091 $BACKUP_DIR/$BACKUP_NAME  --username=$USERNAME --password=$PASSWORD
tar -cvzf $BACKUP_DIR/$BACKUP_NAME.tar.gz $BACKUP_DIR/$BACKUP_NAME

echo "$BACKUP_BUCKET_NAME backed up to $BACKUP_DIR/$BACKUP_NAME.tar.gz"

#aws s3 cp $BACKUP_DIR/$BACKUP_NAME.tar.gz s3//:$S3_BUCKET_NAME
