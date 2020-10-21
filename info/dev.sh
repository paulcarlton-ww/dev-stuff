


https://fmr.zoom.us/s/8756503751


export PYTHONPATH=$PWD
python3 dr backup --labels backup --bucket hsbc-bucket --log-level DEBUG --once --kube-config /home/pcarlton/.kube/config

export AWS_ACCESS_ID=`grep aws_access_key_id ~/.aws/credentials | awk '{print $3}'`
export AWS_SECRET_ACCESS_KEY=`grep aws_secret_access_key ~/.aws/credentials | awk '{print $3}'`

cd /home/pcarlton/src/github.com/paulcarlton-ww/dr/charts/test-data
kubectl apply -f cluster-data.yaml -n kube-system
kubectl apply -f aws-auth.yaml -n kube-system

history | awk '{$1=""; print $0}' | sed s/^\ //g | tail -10

curl -Ls https://fluxcd.io/install | sh && \
sudo mv $HOME/.fluxcd/bin/fluxctl /usr/local/bin/fluxctl

GIT_EMAIL=$(git config -f ~/.gitconfig --get user.email)
GIT_ORG=$(git config -f ~/.gitconfig --get user.name)

fluxctl install \
--git-user=${GIT_ORG} \
--git-email=${GIT_EMAIL} \
--git-url=git@github.com:${GIT_ORG}/gitops-test-config \
--git-path=namespaces,workloads,infra,teams \
--namespace=flux | kubectl apply -f -


aws sts assume-role --role-arn arn:aws:iam::482649550366:role/eks-cluster-viewer --role-session-name eks-view | tee assume.json
export AWS_ACCESS_KEY_ID=$(jq -r '."Credentials"["AccessKeyId"]' assume.json)
export AWS_SECRET_ACCESS_KEY=$(jq -r '."Credentials"["SecretAccessKey"]' assume.json)
export AWS_SESSION_TOKEN=$(jq -r '."Credentials"["SessionToken"]' assume.json)

http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login
kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}"|base64 --decode;echo

kubeadm join 192.168.1.72:6443 --token 5yuybj.dnygs07eov1x7cuu \
    --discovery-token-ca-cert-hash sha256:fa71701197f066e5144ccce2a5ee4e59183b8a7c190c99b2e55a38d657c924c2

aws logs filter-log-events --log-group /aws/eks/ynap-cluster/cluster --log-stream-name-prefix kube-apiserver-audit --page-size 40  --max-items 40 --start-time `date +%s --date='2020-04-22 10:00'` --filter-pattern '{ $.user.username = "paul" && $.responseStatus.code = 403 }' --query '"events"[*]."message"' | sed s/\\\\//g | sed s/\"{/{/ | sed s/}\"/}/ | jq -r '.[] | { "requestURI", "annotations"}'

cd
rm -rf $HOME/src/github.com/paulcarlton-ww/pauluk-baremetal

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

unset KUBECONFIG
mkdir -p $HOME/src/github.com/paulcarlton-ww/pauluk-baremetal
cd $HOME/src/github.com/paulcarlton-ww/pauluk-baremetal
export WKP_ENTITLEMENTS=/home/pcarlton/info/2018-08-31-weaveworks.entitlements
$HOME/wk setup install
export WKP_DEBUG=true
sed s/baremetal-NN/baremetal-`printf %02d $(cat ~/next.txt)`/ /tmp/config.yaml > setup/config.yaml

while [ `openstack server list | grep ACTIVE | wc -l` -lt 6 ]; do echo "`openstack server list | grep ACTIVE | wc -l` servers active";sleep 2;done
$HOME/wk setup run -v
export KUBECONFIG="/home/pcarlton/src/github.com/paulcarlton-ww/pauluk-baremetal/setup/weavek8sops/pauluk-baremetal/kubeconfig"



aws-google-auth --resolve-aliases --idp-id C0203uytv --sp-id 656726301855 --username paul.carlton@weave.works --profile default --region eu-west-1


GOVER=1.14.2
pushd `mktemp -d`
wget https://dl.google.com/go/go${GOVER}.linux-amd64.tar.gz
tar -xvf go${GOVER}.linux-amd64.tar.gz
rm -rf $GOBIN/go
mv go $GOBIN
popd
go version
whereis go

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

export TOOLS_DOWNLOAD_SKIP=y
MINIKUBE_DIR="$HOME/src/github.com/paul-carlton/minikube-env/minikube"
source ${MINIKUBE_DIR}/tools_env_path.sh

# Start minikube
${MINIKUBE_DIR}/minikube_create.sh

# Set environment access to the tools $PATH and add minikube to $no_proxy
source ${MINIKUBE_DIR}/minikube_env.sh

helm upgrade --install --wait frontend \
--namespace bank-app2 \
--set replicaCount=2 \
--set backend=http://backend-podinfo:9898/echo \
podinfo/podinfo

helm upgrade --install --wait backend \
--namespace bank-app2 \
--set hpa.enabled=true \
podinfo/podinfo

c=2
export KUBECONFIG=$HOME/c$c.yaml
 . ~/info/aws-bank.sh
. $HOME/src/github.com/paulcarlton-ww/k8s-dr-utils/venv/bin/activate
set-title $c

cd $HOME/src/github.com/paulcarlton-ww/k8s-backup

export PYTHONPATH=$PWD

history | awk '{$1=""; print $0}' | sed s/^\ //g

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

export MINIKUBE_LOC=$PWD
source "${MINIKUBE_LOC}/minikube/tools_env_path.sh"
source "${MINIKUBE_LOC}/minikube/minikube_env_no_proxy.sh" &>/dev/null

export WORK_DIR=/tmp/rda
export MINIKUBE_LOC=${WORK_DIR}/rda_test/src/github.hpe.com/platform-opshq/minikube-env
source "${MINIKUBE_LOC}/minikube/tools_env_path.sh"
source "${MINIKUBE_LOC}/minikube/minikube_env_no_proxy.sh" &>/dev/null
export KUBECONFIG=${WORK_DIR}/kubeconfig

virsh list --all
vm=$(virsh list --all | awk '/minikube/{print $1}')
if [ -n "${vm}" ];  then
    virsh destroy ${vm}
    virsh undefine minikube
fi
virsh list
virsh net-list
virsh net-destroy minikube-net
virsh net-undefine minikube-net
virsh net-list
rm -rf ~/.minikube

virsh net-destroy vagrant-libvirt
virsh net-undefine vagrant-libvirt
virsh vol-list --pool=default
virsh vol-delete --pool=default vagrant-RDA-cas_onesphere-cas.img
virsh net-list
virsh list


for c in `docker ps -a | grep -v CONT  | grep "Exited" | cut -f1 -d" "`;do docker stop $c;docker rm $c;done
for c in `docker images | grep -v REPO | grep "<none>" | awk '{print $3}'`; do docker rmi -f $c;done;docker images;docker ps -a
for c in `docker images | grep -v REPO | grep "backup" | awk '{print $3}'`; do docker rmi -f $c;done;docker images;docker ps -a


aws ec2 describe-instances --region us-west-1 --profile shared --filters "Name=tag:ClusterName,Values=ncssec*" --query 'Reservations[].Instances[].[InstanceId,State.Name,join(`,`,Tags[?Key==`ClusterName`].Value)]' --output text

aws rds describe-db-instances --region us-west-1 --profile shared --query 'DBInstances[?starts_with(DBInstanceIdentifier, `ncssec`) == `true`].[DBInstanceIdentifier,Endpoint.Address]' --output text

aws rds describe-db-instances --profile shared --region us-west-1 --db-instance-identifier restore-ncssec-pc-du-dev-hpedevops-net

history | awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}'

rds_endpoint=127.0.0.1
mysql -h $rds_endpoint --user=root -p$root_pwd -e "create database testdb"
mysql -h $rds_endpoint --user=root -p$root_pwd -e "GRANT ALL PRIVILEGES ON testdb.* TO 'testdb_user'@'%' IDENTIFIED BY 'htestdb_pws'"
mysql -h $rds_endpoint --user=testdb_user -ptestdb_pws  -e "create table IF NOT EXISTS \`keys\` (id VARCHAR(50) NOT NULL, \`keys\` VARCHAR(255) NOT NULL, created DATETIME NOT NULL, modified DATETIME NOT NULL, PRIMARY KEY (id))" testdb

kubectl --kubeconfig $AWS_KUBECONFIG -nms delete job,po --all
kubectl --kubeconfig $AWS_KUBECONFIG --namespace=ms get pods

sudo systemctl daemon-reload
sudo systemctl restart docker

docker stop registry
docker rm registry
docker run -d -p 5000:5000 --restart=always --name registry -v /etc/hosts:/etc/hosts -v $PWD/certs:/certs -v hyper/registry/config.yml:/etc/docker/registry/config.yml -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/hyper.pem -e REGISTRY_HTTP_TLS_KEY=/certs/hyper-key.pem registry:2
sleep 5
docker logs --details registry

docker exec registry /bin/sh -c "nslookup `hostname`"

for c in `env | cut -f1 -d= | grep -i proxy`; do unset $c;done

docker system prune -f --all
docker system prune -f --volumes

aws --output json ecr describe-repositories | jq -r ".repositories[] | .repositoryName"
aws --output json ecr list-images --repository-name staging/panormos/ui | jq -r ".imageIds[] | .imageTag"





aws-google-auth --resolve-aliases --idp-id C0203uytv --sp-id 656726301855 --username paul.carlton@weave.works --profile default --region eu-west-2
history | grep eks
eksctl get iamidentitymapping --cluster pcuk
kubectl get clusterroles
kubectl get clusterroles view -o yaml
kubectl get clusterroles edit -o yaml
cd info/eks/
grep -r aggregate-to-edit *
grep -r aggregate-to-edit kube-system/
grep -C 5 -r aggregate-to-edit kube-system/
kubectl get clusterroles view -o yaml
grep -A 5 -r aggregationRule kube-system/
grep -C 5 -r aggregate-to-view kube-system/
kubectl apply -f ../namespace.yaml
grep -C 5 -r aggregate-to-view kube-system/
kubectl apply -f ../namespace.yaml
kubectl apply -f ../view-role.yaml
eksctl create iamidentitymapping --cluster pcuk --arn arn:aws:sts::482649550366:assumed-role/eks-view/eks-view --group team1-view
eksctl create iamidentitymapping --cluster pcuk --arn arn:aws:iam::482649550366:role/eks-view --group team1-view
eksctl get iamidentitymapping --cluster pcuk
kubectl get rolebindings -n team1
kubectl get rolebindings view -n team1 -o yaml
kubectl get clusterrole view --o yaml
kubectl get clusterrole view -o yaml
kubectl apply -f ../view-role.yaml
kubectl delete -f ../view-role.yaml
kubectl apply -f ../view-role.yaml
eksctl get iamidentitymapping --cluster pcuk
eksctl delete iamidentitymapping --cluster pcuk --arn arn:aws:iam::482649550366:role/eks-view --group team1-view
eksctl delete iamidentitymapping --cluster pcuk --arn arn:aws:iam::482649550366:role/eks-view
eksctl get iamidentitymapping --cluster pcuk
eksctl create iamidentitymapping --cluster pcuk --arn arn:aws:iam::482649550366:role/eks-view --group team1-viewer
eksctl get iamidentitymapping --cluster pcuk
eksctl delete iamidentitymapping --cluster pcuk --arn arn:aws:iam::482649550366:role/eks-view
eksctl create iamidentitymapping --cluster pcuk --arn arn:aws:iam::482649550366:role/eks-view --group team1-viewers
eksctl get iamidentitymapping --cluster pcuk
aws iam create-role
aws iam create-role --role-name eks-cluster-viewer
cd ..
awas sts get-identity
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


source ~/info/aws.sh pauluk-view
aws sts assume-role --role-arn arn:aws:iam::482649550366:role/eks-cluster-viewer --role-session-name eks-view | tee assume.json
unset AWS_SESSION_TOKEN
aws sts assume-role --role-arn arn:aws:iam::482649550366:role/eks-cluster-viewer --role-session-name eks-view | tee assume.json
export AWS_ACCESS_KEY_ID=$(jq -r '."Credentials"["AccessKeyId"]' assume.json)
export AWS_SECRET_ACCESS_KEY=$(jq -r '."Credentials"["SecretAccessKey"]' assume.json)
export AWS_SESSION_TOKEN=$(jq -r '."Credentials"["SessionToken"]' assume.json)
