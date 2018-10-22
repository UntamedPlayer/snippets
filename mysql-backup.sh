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

BACKUP_NAME=mysql-$DB_NAME-$(date +"%Y%m%d%H%M")

ssh -fN -o ExitOnForwardFailure=yes $NODE_USER@$NODE_HOSTNAME -i $IDENTITY_FILE -L3307:$DB_HOSTNAME:3306

mysqldump -h127.0.0.1 -P3307 --user=$DB_USER --password=$DB_PASSWORD $DB_NAME > $BACKUP_NAME.sql

# Add aws-cli copy to S3 bucket 
