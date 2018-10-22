USAGE="usage: mysql-backup.sh -h node_hostname -i identity_file -d db_hostname [-n db_name] -u db_user -p db_password [-b backup_directory]\n\t-h  / --node-hostname: IP or hostname of a Kubernetes node\n\t-i  / --identity-file: Optional, defaults to ec2-keypairs/ailabs-cluster-node.pem\n\t-d  / --db-hostname: DB Hostname or RDS Endpoint\n\t-n  / --db-name: Optional defaults to axiom\n\t-u  / --db-user: Optional defaults to qa_master\n\t-p  / --db-password: DB password\n\t-b  / --backup-directory: Optional defaults to ./"
NODE_USER="ec2-user"
NODE_HOSTNAME=""
IDENTITY_FILE=""
DB_HOSTNAME=""
DB_NAME="axiom"
DB_USER="qa"
DB_PASSWORD=""
BACKUP_DIRECTORY=./

PARAMS=""

while (( "$#" )); do
  case "$1" in
    "-h" | "--help") echo $USAGE; exit 0 ;;
    "-k" | "--node-hostname") NODE_HOSTNAME=$2; shift 2 ;;
    "-i" | "--identity-file") IDENTITY_FILE=$2; shift 2 ;;
    "-d" | "--db-hostname") DB_HOSTNAME=$2; shift 2 ;;
    "-n" | "--db-name") DB_NAME=$2; shift 2 ;;
    "-u" | "--db-user") DB_USER=$2; shift 2 ;;
    "-p" | "--db-password") DB_PASSWORD=$2; shift 2 ;;
    "-b" | "--backup-directory") BACKUP_DIRECTORY=$2; shift 2 ;;
    * )
      break
      PARAMS="$PARAMS $1"
      shift
  esac
done
eval set -- "$PARAMS"

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
