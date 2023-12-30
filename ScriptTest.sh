GOODTOT=$(find test/good -type f | wc -l)
GOOD=0
FAILTOT=$(find test/syn-err -type f | wc -l)
GOOD=0
for file in test/good/*
do
    ./bin/tpcas $file
    RES=$?
    echo "$file -> $RES"
    if [ $RES = 0 ]; then
       ((GOOD=GOOD+1))
    fi
done

for file in test/syn-err/*
do
    ./bin/tpcas $file
    RES=$?
    echo "$file -> $RES"
    if [ $RES = 1 ]; then
       ((FAIL=FAIL+1))
    fi
done
echo "
Tests bons réussies : $GOOD/$GOODTOT
Tests erreur syntaxe/lexicale réussies: $FAIL/$FAILTOT

Conclusion tests réussies : $(($GOOD+$FAIL))/$(($GOODTOT+$FAILTOT))"