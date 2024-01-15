test_exit() {
  # shellcheck disable=SC2181
  if [ $? -ne 0 ]; then
    echo ""
    echo "failed to '$1'"
    echo ""
    echo "Press any key to exit"
    read -n 1 -s
    exit 1
  fi
}

get_logs() {
  for p in $(kubectl get pods -o=name | grep fetch-cronjob | sed "s/^.\{4\}//"); do
    echo ---------------------------
    echo $p
    echo ---------------------------
    kubectl logs $p
  done
}

kind delete cluster
kind create cluster --config=cluster.yaml

test_exit 'kind create cluster'

cd ./service-scrubber

docker build -t scrubber:v1 .

test_exit 'docker build'

cd ..

kind load docker-image scrubber:v1

test_exit 'kind load docker-image'

docker image rm scrubber:v1

test_exit 'docker image rm'

kubectl apply -f deployment.yaml

test_exit 'kubectl apply deployment'

kubectl apply -f service.yaml

test_exit 'kubectl apply service'

kubectl apply -f cron.yaml

test_exit 'kubectl apply cron'

while true; do
  echo ""
  echo "waiting 10s to get logs"
  sleep 10
  clear
  get_logs
done
