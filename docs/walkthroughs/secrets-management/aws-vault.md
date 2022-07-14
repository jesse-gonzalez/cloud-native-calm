# Configure AWS as Dynamic Secrets Engine

vault secrets enable -path=aws aws

export AWS_ACCESS_KEY_ID=$(vault kv get -field=aws_access_key_id nutanix/calm)
export AWS_SECRET_ACCESS_KEY=$(vault kv get -field=aws_access_key_secret nutanix/calm)

vault write aws/config/root \
    access_key=$AWS_ACCESS_KEY_ID \
    secret_key=$AWS_SECRET_ACCESS_KEY \
    region=us-east-1

vault write aws/roles/demo-role credential_type=iam_user policy_document=-<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1426528957000",
      "Effect": "Allow",
      "Action": [
        "ec2:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF

vault read aws/creds/demo-role

vault lease revoke aws/creds/demo-role/iih1TmQbdvzNo5Ip0gaeBVan