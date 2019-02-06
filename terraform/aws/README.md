```
cat <<EOF > ./kabu-additional-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "ec2:RequestSpotInstances",
                "ec2:DescribeSpotInstanceRequests",
                "ec2:CancelSpotInstanceRequests",
                "elasticloadbalancing:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "$(aws iam get-user --user-name pcf_om_user | jq -r .User.Arn)"
        }
    ]
}
EOF

aws iam put-user-policy --user-name pcf_om_user --policy-name kabu-additional-policy --policy-document "$(cat ./kabu-additional-policy.json)"
```