#Author:  Sebastián Urciuoli 
#Email:   s.urciuoli@gmail.com
#License: MIT

prog=$1
cases_path=$2
output=$3

if [ -z "$output" ]
then 
  output=$cases_path
fi 

if [ -z "$prog" ] || ! [ -f "$prog" ] || [ -z "$cases_path" ] || ! [ -d "$cases_path" ] || ! [ -d "$output" ]
then 
  echo ERROR
  echo Usage: 
  echo 
  echo "  ./test.sh PROG CASES [OUTPUT_DIR]"
  echo 
  echo where:
  echo "- PROG   must be a valid executable file"
  echo "- CASES  must be a valid directory where cases are present"
  echo "- OUTPUT if present, must also be a valid directory where output files will be saved. "
  echo "         If not present, CASES is used."
  exit 1
fi 

fst_err_fout=""
fst_err_fexp=""
failed=0
ok=0

for fin in "$cases_path"/*.in.txt
do
  fname=`basename -s .in.txt $fin`
  fexp="$cases_path/$fname".out.txt
  fout="$output/$fname".mine.txt
  
  tabs 10
  echo -en "Testing case '$fname'...\t"
  
  start=`date +%s`
  
  if $prog < $fin 1> $fout 2> /dev/null
  then
    ok=1  
    end=`date +%s`
	runtime=$((end-start))
	echo -n "$runtime"s
	
	if ! diff -q $fout $fexp > /dev/null
	then 
	  tabs 5 > /dev/null
	  echo -ne "\tOutput not expected"
	  
	  if [ -z $fst_err_fexp ]
	  then 
	    fst_err_fexp=$fexp
		fst_err_fout=$fout
	  fi
	fi 
	echo 
	
  else
    failed=1
    echo Execution failed
  fi 
done

if [ $failed -eq 1 ]
then 
  echo
  if [ $ok -eq 1 ]
  then 
    echo -e In one or more cases the execution failed. This may be due the program crashed.
  else 
    echo -e In one or more cases the execution failed. This may be due the program crashed or \"$prog\" is not a valid executable program name.
  fi 
fi 

if ! [ -z "$fst_err_fexp" ]
then 
  echo 
  if [ $failed -eq 1 ]
  then 
    echo -ne "In addition, same cases were incorrect. "
  else 
    echo -ne "Same cases were incorrect. "
  fi 
  echo To see the differences, use, e.g:
  echo 
  echo -e "  diff \"$fst_err_fexp\" \"$fst_err_fout\""
  echo
  echo -e \(The line above shows the differences between the expected and your solutions\'s output, respectively, in the first error encountered\).
fi 

if [ $failed -eq 0 ] && [ -z "$fst_err_fexp" ] 
then
  echo 
  echo CONGRATULATIONS!
  echo -e "All cases where successfully passed! :)"
fi 
