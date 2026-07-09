1. Run Terraform to reprovision the NAT gateway
2. Create the EKSCTL Cluster
ekctl create cluster -f EKS-Cluster.yaml
3. aws eks update-cluster-config --name EKS-DEV --region ap-southeast-2 --no-deletion-protection
4. eksctl create iamidentitymapping --cluster EKS-DEV --region ap-southeast-2 --arn arn:aws:iam::865983312994:role/github-actions-role --group system:masters --username github-actions-role

