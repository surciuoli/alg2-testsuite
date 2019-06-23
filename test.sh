#Author:  Sebastián Urciuoli 
#Email:   s.urciuoli@gmail.com
#License: MIT

java=0
argc=0

for arg in "$@"
do
    if [ "$arg" == "--java" ]
	then
	  java=1
	else 
	  args[argc]=$arg
	  argc=$((argc+1))
	fi 
done

prog=${args[0]}
cases_path=${args[1]}
output=${args[2]}

if [ -z "$output" ]
then 
  output=$cases_path
fi 

if ! [ -d "$output" ] && ! [ -f "$output" ]
then
  mkdir "$output"
fi

if [ -z "$prog" ] || ([ $java -eq 0 ] && ! [ -f "$prog" ]) || [ -z "$cases_path" ] || ! [ -d "$cases_path" ] || [ -f "$output" ]
then 
  echo ERROR
  echo Usage: 
  echo 
  echo "  ./test.sh PROG CASES [OUTPUT_DIR]"
  echo 
  echo where:
  echo "- PROG   must be a valid executable file"
  echo "- CASES  must be a valid directory where cases are present"
  echo "- OUTPUT if present, must also be directory where output files will be saved. "
  echo "         If not present, CASES is used."
  exit 1
fi 

fst_err_fout=""
fst_err_fexp=""
failed=0
ok=0

# echo cases: $cases_path

for fin in "$cases_path"/*.in.txt
do
  fname=`basename -s .in.txt "$fin"`
  fexp="$cases_path/$fname".out.txt
  fout="$output/$fname".mine.txt
  
  tabs 10
  echo -en "Testing case '$fname'...\t"
  
  start=`date +%s`
  
  if [ $java -eq 1 ]
  then 
    java $prog <"$fin" 1>"$fout" 2>/dev/null
  else 
    $prog <"$fin" 1>"$fout" 2>/dev/null
  fi 
  
  # echo fname: $fname
  # echo input: $fin
  # echo output: $fout
  
  if [ $? -eq 0 ]
  then
    ok=1  
    end=`date +%s`
	runtime=$((end-start))
	echo -n "$runtime"s
	
	if ! diff -bq --strip-trailing-cr "$fout" "$fexp" > /dev/null
	then 
	  tabs 5 > /dev/null
	  echo -ne "\tOutput not expected"
	  
	  if [ -z "$fst_err_fexp" ]
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
  	if [ $java -eq 0 ]
	then
	  echo -e In one or more cases the execution failed. This may be due the program crashed or \"$prog\" is NOT a valid EXECUTABLE program.
	else 
	  echo -e In one or more cases the execution failed. This may be due the program crashed or \"$prog\" is NOT a valid JAVA class.
	fi
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
  echo -e "  diff -b --strip-trailing-cr \"$fst_err_fexp\" \"$fst_err_fout\""
  echo
  echo -e \(The line above shows the differences between the expected and your solutions\'s output, respectively, in the first error encountered. The -b option tells diff to ignore all space changes and --strip-trailing-cr to ignore trailing carriage return. For more information, execute \'diff --help\' or visit: https://www.gnu.org/software/diffutils/manual/html_node/diff-Options.html\).
fi 

if [ $failed -eq 0 ] && [ -z "$fst_err_fexp" ] 
then
  echo 
  echo CONGRATULATIONS!
  echo -e "All cases where successfully passed! :)"
fi 
