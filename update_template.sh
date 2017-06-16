if [ ! -d ytx-pod-template ]; then
  git clone git@gitlab.yintech.net:ytx-ios/ytx-pod-template.git
fi

cd ytx-pod-template
git pull

cp -rp .gitlab-ci.yml ../
cp -rp .slather.yml ../
cp -rp coverage.sh ../
cp -rp buildpod.sh ../
cp -rp cleanBranch.sh ../
cp -rp cleanPod.sh ../
cp -rp download_zip.sh ../
cp -rp lint_binary.sh ../
cp -rp lint_source.sh ../
cp -rp merge_request.sh ../
cp -rp pod_package.sh ../
cp -rp update_template.sh ../
cp -rp push_yintech.sh ../
cp -rp release_pb_app.sh ../
cp -rp zip.sh ../
cp -rp test.sh ../

