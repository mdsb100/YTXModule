MIN_COVERAGE_RATE=$1
if [[ ! $MIN_COVERAGE_RATE ]]; then
  MIN_COVERAGE_RATE='75'
fi
echo "minimum converage rage:$MIN_COVERAGE_RATE"
PROJECT_NAME=${PWD##*/}
sed -i "" "s/POD_NAME/$PROJECT_NAME/g" .slather.yml
slather coverage -x
COVERAGE=$(slather coverage -s | grep -o -E '(\d+\.\d+)%' | tail -1 | cut -d '%' -f1)

if ! echo "$COVERAGE $MIN_COVERAGE_RATE -p" | dc | grep > /dev/null ^-; then
  echo "current:$COVERAGE > min:$MIN_COVERAGE_RATE"
  echo 'pass'
else
  echo "current:$COVERAGE <  min:$MIN_COVERAGE_RATE"
  echo 'no pass'
  exit 1
fi