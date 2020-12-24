WORKSPACE=$1
BUILD=$2

set -e

echo "WORKSPACE:" $WORKSPACE
echo "BUILD:" $BUILD
cat "$WORKSPACE" > /dev/null
cat "$BUILD" > /dev/null

workspace=$(cat << End
http_archive(
    name = "com_grail_bazel_compdb",
    strip_prefix = "bazel-compilation-database-master",
    urls = ["https://github.com/grailbio/bazel-compilation-database/archive/master.tar.gz"],
)
End
)

targets=$(echo -n $(cat $(pwd)/target_list.txt))

build_targets=
compl_targets=
for t in $targets;
do
   if [[ ! -z $t ]]; then
       IFS='->'; read -ra TA <<< "$t"; unset IFS
       compl_targets=$compl_targets\"${TA[-1]}\",
       build_targets="$build_targets ${TA[0]}"
   fi
done

build=$(cat << End
load("@com_grail_bazel_compdb//:aspects.bzl", "compilation_database")

compilation_database(
    name = "comp_db",
    targets = [
        $compl_targets
    ],
)
End
)
echo "$build"
echo "targets"
echo "$build_targets"
echo "$workspace" >> $WORKSPACE
echo "$build" >> $BUILD

bazelisk build --keep_going -- $targets