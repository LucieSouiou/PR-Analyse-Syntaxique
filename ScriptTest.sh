for file in test/good/*
do
    ./bin/tpcas $file
    echo "$file -> $?"
done

for file in test/syn-err/*
do
    ./bin/tpcas $file
    echo "$file -> $?"
done