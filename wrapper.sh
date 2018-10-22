export DEBUG=1
[ "$DEBUG" == '1' ] && set -x
source ./mysql-backup.sh --node-hostname 34.217.41.118 --identity-file /Users/jimherndon/Workspaces/advisoril-infrastructure-v2/ec2-keypairs/ailabs-cluster-node.pem --db-hostname ar1bwl2q25amm9i.cfhpxxd2otwa.us-west-2.rds.amazonaws.com --db-user qa_master --db-password <password>
[ "$DEBUG" == '1' ] && set +x