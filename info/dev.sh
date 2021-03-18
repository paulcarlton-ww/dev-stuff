#!/bin/bash

history | awk '{$1=""; print $0}' | sed s/^\ //g | tail -10

GIT_EMAIL=$(git config -f ~/.gitconfig --get user.email)
GIT_ORG=$(git config -f ~/.gitconfig --get user.name)

aws sts assume-role --role-arn arn:aws:iam::482649550366:role/eks-cluster-viewer --role-session-name eks-view | tee assume.json
export AWS_ACCESS_KEY_ID=$(jq -r '."Credentials"["AccessKeyId"]' assume.json)
export AWS_SECRET_ACCESS_KEY=$(jq -r '."Credentials"["SecretAccessKey"]' assume.json)
export AWS_SESSION_TOKEN=$(jq -r '."Credentials"["SessionToken"]' assume.json)

http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login
kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}"|base64 --decode;echo

kubeadm join 192.168.1.72:6443 --token 5yuybj.dnygs07eov1x7cuu \
    --discovery-token-ca-cert-hash sha256:fa71701197f066e5144ccce2a5ee4e59183b8a7c190c99b2e55a38d657c924c2

aws logs filter-log-events --log-group /aws/eks/ynap-cluster/cluster --log-stream-name-prefix kube-apiserver-audit --page-size 40  --max-items 40 --start-time `date +%s --date='2020-04-22 10:00'` --filter-pattern '{ $.user.username = "paul" && $.responseStatus.code = 403 }' --query '"events"[*]."message"' | sed s/\\\\//g | sed s/\"{/{/ | sed s/}\"/}/ | jq -r '.[] | { "requestURI", "annotations"}'

openstack server create --image centos7 --security-group f42c917c-8883-4e35-b9be-0c4a762d4b31 --security-group k8s --key-name server --flavor k8s2 --nic net-id=$fixed_net controller
fixed_net=$(openstack network show test -f value -c id)
openstack server add floating ip controller $(openstack floating ip list -f value -c ID --status DOWN | head -1)
openstack server list
ssh -o StrictHostKeyChecking=no -i ~/info/servers/id_rsa centos@10.20.20.

openstack server delete controller

openstack server delete centos1
openstack server delete centos2
openstack server delete centos3
openstack server delete centos4
openstack server delete centos5
openstack server delete centos6

fixed_net=$(openstack network show test -f value -c id)
openstack server create --image centos7 --security-group f42c917c-8883-4e35-b9be-0c4a762d4b31 --security-group k8s --key-name server --flavor k8s2 --nic net-id=$fixed_net centos1
openstack server create --image centos7 --security-group f42c917c-8883-4e35-b9be-0c4a762d4b31 --security-group k8s --key-name server --flavor k8s2 --nic net-id=$fixed_net centos2
openstack server create --image centos7 --security-group f42c917c-8883-4e35-b9be-0c4a762d4b31 --security-group k8s --key-name server --flavor k8s2 --nic net-id=$fixed_net centos3
openstack server create --image centos7 --security-group f42c917c-8883-4e35-b9be-0c4a762d4b31 --security-group k8s --key-name server --flavor k8s2 --nic net-id=$fixed_net centos4
openstack server create --image centos7 --security-group f42c917c-8883-4e35-b9be-0c4a762d4b31 --security-group k8s --key-name server --flavor k8s2 --nic net-id=$fixed_net centos5
openstack server create --image centos7 --security-group f42c917c-8883-4e35-b9be-0c4a762d4b31 --security-group k8s --key-name server --flavor k8s2 --nic net-id=$fixed_net centos6
openstack server add floating ip centos1 $(openstack floating ip list -f value -c ID --status DOWN | head -1)
openstack server add floating ip centos2 $(openstack floating ip list -f value -c ID --status DOWN | head -1)
openstack server add floating ip centos3 $(openstack floating ip list -f value -c ID --status DOWN | head -1)
openstack server add floating ip centos4 $(openstack floating ip list -f value -c ID --status DOWN | head -1)
openstack server add floating ip centos5 $(openstack floating ip list -f value -c ID --status DOWN | head -1)
openstack server add floating ip centos6 $(openstack floating ip list -f value -c ID --status DOWN | head -1)
expr `cat ~/next.txt` + 1 > ~/next.txt

openstack server list -f yaml -c Name -c Networks | sed s/-\ Name/\ \ \ \ -\ role\:\ master#\ \ \ \ \ \ name/ | tr '#' '\n' | sed s/Networks\:\ test=/\ \ \ \ privateAddress:\ / | sed s/,\ /,\ \ \ \ \ \ publicAddress\:\ / | awk '/,/{sub(/,/,"\n")} 1' | sed s/\:\ /\:\ \"/  | awk '{ print ""$0"\""}'  | sed  '1s/master/worker/' | sed  '5s/master/worker/' | sed  '9s/master/worker/' > /tmp/machines.yaml
cat ~/config.yaml  /tmp/machines.yaml > /tmp/config.yaml

aws-google-auth --resolve-aliases --idp-id C0203uytv --sp-id 656726301855 --username paul.carlton@weave.works --profile default --region eu-west-1

cd $GOPATH/src/k8s.io/kubernetes
hack/install-etcd.sh
export PATH="/home/pcarlton/src/k8s.io/kubernetes/third_party/etcd:${PATH}"
nohup sudo PATH=$PATH FEATURE_GATES="AdvancedAuditing=true,DynamicAuditing=true" \
    RUNTIME_CONFIG="auditregistration.k8s.io/v1alpha1=true" API_HOST_IP=192.168.1.72 \
    AUDIT_POLICY_FILE=/home/pcarlton/src/github.com/paulcarlton-ww/dev-stuff/info/audit.yaml \
    hack/local-up-cluster.sh > ~/work/kube.log 2>&1 &
tail -f ~/work/kube.log

export KUBECONFIG=/var/run/kubernetes/admin.kubeconfig


cd ../../istio/istio-1.5.1/
./bin/istioctl manifest apply --set profile=demo
kubectl label namespace test istio-injection=enabled

 for c in `curl -s -H "X-Auth-Token: ${PACKET_API_KEY}" https://api.packet.net/projects/${project} | jq -r '.devices[] | .href'` \
    do curl -s -H "X-Auth-Token: ${PACKET_API_KEY}" https://api.packet.net$c | \
    jq -r '. | .hostname + " ansible_host=" + (."ip_addresses"[] | select(.public==true and .address_family==4)).address';done

for c in `curl -s -H "X-Auth-Token: ${PACKET_API_KEY}" https://api.packet.net/projects/${project} | jq -r '.devices[] | .href'`; \
 do curl -s -X POST -H "X-Auth-Token: ${PACKET_API_KEY}" https://api.packet.net$c/actions?type=reboot;done

iptables -A INPUT -s 192.168.1.1 -j ACCEPT
iptables -A OUTPUT -d 192.168.1.1 -j ACCEPT
iptables -P INPUT DROP
iptables -P OUTPUT DROP

sudo openvpn --daemon --config ~/info/packet-ams1.config --auth-user-pass ~/info/vpn.txt

  # ProxyCommand ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null  root@${public_dns__name_bastion} nc %h %p

curl -s -H "X-Auth-Token: ${PACKET_API_KEY}" https://api.packet.net/volumes?ewr1

curl -X PUT -H "X-NSONE-Key: ${NS1_API_KEY}" \
    -d '{"zone":"pc.packet.weaveworks.net", "domain":"gitlab.pc.packet.weaveworks.net", "type":"A", "answers":[{"answer":["147.75.78.77"]}]}' \
    https://api.nsone.net/v1/zones/pc.packet.weaveworks.net/gitlab.pc.packet.weaveworks.net/A

curl -X PUT -H "X-NSONE-Key: ${NS1_API_KEY}" -d '{"zone":"example.com", "domain":"arecord.example.com", "type":"A", "answers":[{"answer":["1.2.3.4"]}]}' https://api.nsone.net/v1/zones/example.com/arecord.example.com/A


aws ec2 describe-instances --region us-west-1 --profile shared --filters "Name=tag:ClusterName,Values=ncssec*" --query 'Reservations[].Instances[].[InstanceId,State.Name,join(`,`,Tags[?Key==`ClusterName`].Value)]' --output text

aws rds describe-db-instances --region us-west-1 --profile shared --query 'DBInstances[?starts_with(DBInstanceIdentifier, `ncssec`) == `true`].[DBInstanceIdentifier,Endpoint.Address]' --output text

sudo systemctl daemon-reload
sudo systemctl restart docker

docker stop registry
docker rm registry
docker run -d -p 5000:5000 --restart=always --name registry -v /etc/hosts:/etc/hosts -v $PWD/certs:/certs -v hyper/registry/config.yml:/etc/docker/registry/config.yml -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/hyper.pem -e REGISTRY_HTTP_TLS_KEY=/certs/hyper-key.pem registry:2
sleep 5
docker logs --details registry

docker exec registry /bin/sh -c "nslookup `hostname`"

docker system prune -f --all
docker system prune -f --volumes

aws --output json ecr describe-repositories | jq -r ".repositories[] | .repositoryName"
aws --output json ecr list-images --repository-name staging/panormos/ui | jq -r ".imageIds[] | .imageTag"

aws sts get-identity
aws sts get-caller-identity
aws sts get-caller-identity | jq -r '"Account"'
aws sts get-caller-identity | jq -r '."Account"'
sed s/ACCOUNT_ID/$(aws sts get-caller-identity | jq -r '."Account"')/ role-template.json
sed s/ACCOUNT_ID/$(aws sts get-caller-identity | jq -r '."Account"')/ role-template.json > /tmp/role.json
aws iam create-role --role-name eks-cluster-viewer --assume-role-policy-document role.json
aws iam create-role --role-name eks-cluster-viewer --assume-role-policy-document /tmp/role.json
cat /tmp/role.json
aws iam create-role --role-name eks-cluster-viewer --assume-role-policy-document /file:///tmp/role.json
aws iam create-role --role-name eks-cluster-viewer --assume-role-policy-document /file://tmp/role.json
cat role-template.json
sed s/ACCOUNT_ID/$(aws sts get-caller-identity | jq -r '."Account"')/ role-template.json > /tmp/role.json
cat /tmp/role.json
aws iam create-role --role-name eks-cluster-viewer --assume-role-policy-document file:///tmp/role.json
aws iam create-role --role-name eks-team1-viewer --assume-role-policy-document file:///tmp/role.json
eksctl get iamidentitymapping --cluster pcuk
eksctl create iamidentitymapping --cluster pcuk --arn arn:aws:iam::482649550366:role/eks-cluster-viewer --group cluster-viewers
eksctl get iamidentitymapping --cluster pcuk
aws iam create-group
aws iam create-group --group-name eks-team1
aws iam create-group --group-name eks-viewer
aws iam attach-group-policy --group-name eks-viewer
aws iam create-policy --policy-name assume-eks-viewer --policy-document file:///tmp/assume.json
vim assume-template.json
sed s/ACCOUNT_ID/$(aws sts get-caller-identity | jq -r '."Account"')/ assume-template.json | sed s/ROLE_NAME/$ROLE_NAME/ > /tmp/assume.json
ROLE_NAME=eks-cluster-viewer
sed s/ACCOUNT_ID/$(aws sts get-caller-identity | jq -r '."Account"')/ assume-template.json | sed s/ROLE_NAME/$ROLE_NAME/ > /tmp/assume.json
aws iam create-policy --policy-name assume-eks-viewer --policy-document file:///tmp/assume.json
aws iam attach-group-policy --group-name eks-viewer --policy-arn arn:aws:iam::482649550366:policy/assume-eks-viewer
aws iam add-user-to-group --group-name eks-viewer --user-name pauluk-view
eksctl get iamidentitymapping --cluster pcuk
kubectl get custerrolebindings
kubectl get clusterrolebindings
kubectl apply -f clusterrole.yaml
kubectl get clusterrolebindings
kubectl get clusterrolebindings cluster-viewers -o yaml
kubectl get clusterrolebindings cluster-viewer -o yaml
kubectl get clusterrolebindings viewer -o yaml
eksctl get iamidentitymapping --cluster pcuk
kubectl apply -f view-clusterrole.yaml
kubectl get clusterrolebindings viewer -o yaml

aws sts assume-role --role-arn arn:aws:iam::482649550366:role/eks-cluster-viewer --role-session-name eks-view | tee assume.json
unset AWS_SESSION_TOKEN
aws sts assume-role --role-arn arn:aws:iam::482649550366:role/eks-cluster-viewer --role-session-name eks-view | tee assume.json
export AWS_ACCESS_KEY_ID=$(jq -r '."Credentials"["AccessKeyId"]' assume.json)
export AWS_SECRET_ACCESS_KEY=$(jq -r '."Credentials"["SecretAccessKey"]' assume.json)
export AWS_SESSION_TOKEN=$(jq -r '."Credentials"["SessionToken"]' assume.json)
