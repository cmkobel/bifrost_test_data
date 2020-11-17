#/bin/bash
#pass mongodb key as variable
export BIFROST_DB_KEY="${BIFROST_DB_KEY:-$1}"
export BIFROST_RUN_DIR="${BIFROST_RUN_DIR:-$PWD}"; \
export BIFROST_CONFIG_DIR="${BIFROST_CONFIG_DIR:-$PWD}"; \
cd read_data; \
bash download_S1.sh; \
cd $BIFROST_RUN_DIR; \
docker run \
    --network="host" \
    --env BIFROST_DB_KEY \
    --mount type=bind,source=$BIFROST_RUN_DIR,target=$BIFROST_RUN_DIR \
    ssidk/bifrost_run_launcher:latest \
        -pre $BIFROST_CONFIG_DIR/pre.sh \
        -per $BIFROST_CONFIG_DIR/per_sample.sh \
        -post $BIFROST_CONFIG_DIR/post.sh \
        -reads $BIFROST_RUN_DIR/read_data \
        -meta $BIFROST_RUN_DIR/run_metadata.tsv \
        -name bifrost_test \
        -out $BIFROST_RUN_DIR/bifrost_test_output; 
# for IMAGE in bifrost_min_read_check
for IMAGE in bifrost_min_read_check bifrost_whats_my_species bifrost_assemblatron bifrost_ssi_stamper bifrost_ariba_mlst bifrost_ariba_resfinder bifrost_ariba_virulencefinder bifrost_ariba_plasmidfinder
do
    echo "Downloading and installing $IMAGE"
    docker run \
        --network="host" \
        --env BIFROST_DB_KEY \
        ssidk/$IMAGE:latest \
        --install;
done

mv bifrost_test_output output
cd bifrost_test_output;
bash run_script.sh;
