#!/bin/bash
read -p 'Please Enter Start Date(example:20191112): ' a
read -p 'Please Enter End Date(example:20201112): ' b
read -p 'Only need working days?(yes/no): ' c
read -p 'Minimum submission per day(0-10): ' d
read -p 'Maximum submission per day(1-99): ' e
read -p 'Enter Your github user.name: ' f
read -p 'Enter Your github user.email: ' g
read -p 'Enter Your github token or Password: ' h
read -p 'Please Create a private repository in your GitHub called my-history https://github.com/new' i
git config --global user.email "${g}"
g=`echo $g | sed "s/@/%40/g"`
git config --global user.name "${f}"
git clone https://${g}:${h}@github.com/${f}/my-history.git
git remote add origin git@github.com:${f}/my-history.git
cd my-history
###Check Enter Format
if [ ${#a} -ne 8 ];then
    echo "##Err:Check Your Start Date Format"
    exit
fi
if [ -n "$(echo $a| sed -n "/^[0-9]\+$/p")" ];then
  ok=1
else
    echo "Err:Check Your Start Date Format"
    exit
fi

if [ ${#b} -ne 8 ];then
        echo "Err:CCheck Your End Date Format"
        exit
fi
if [ -n "$(echo $a| sed -n "/^[0-9]\+$/p")" ];then
    ok=1
else
    echo "Err:Check Your End Date Format"
    exit
fi

if [ $a -gt $b ];then
    echo "Err:Start Date Should Before End"
    exit
fi


case $c in
yes | y)
      cc=1;;
no | n)
      cc=0;;
*)
     echo "Err:Only need working days? choice yes/no"
         exit
esac

if [ -n "$(echo $d| sed -n "/^[0-9]\+$/p")" ];then
  ok=1
else
    echo "Err:Check Your Maximum submission per day Format"
    exit
fi

if [ -n "$(echo $e| sed -n "/^[0-9]\+$/p")" ];then
  ok=1
else
    echo "Err:Check Your Minimum submission per day Format"
    exit
fi

if [ $d -gt $e ];then
    echo "Err:Minimum should not More than Maximum "
    exit
fi

####
for i in `seq 1 2000`;do
        if [ $a -gt $b ];then
                break
        fi
        if [ $cc -eq 1 ] && [ `date -d ${a} +%w` -eq 6 ];then
                a=`date -d "${a} +1 day" +%Y%m%d)`
                continue
        fi
        if [ $cc -eq 1 ] && [ `date -d ${a} +%w` -eq 0 ];then
                a=`date -d "${a} +1 day" +%Y%m%d)`
                continue
        fi

        yyyy=$(($a/10000))
        mm=$((($a-$a/10000*10000)/100))
        dd=$(($a%100))
        if [ ${#dd} -ne 2 ];then
                dd="0$dd"
        fi
        if [ ${#mm} -ne 2 ];then
                mm="0$mm"
        fi
        date1="$yyyy-$mm-$dd"
        min=$d
        max=$(($e-$min+1))
        num=$(date +%s%N)
        rnd=$(($num%$max+$min))
        for i in `seq 1 ${rnd}`;do
                time3=$(date "+%H:%M:%S")
                #echo "${date1}T${time3}"
                echo "${time3} on ${date1}" > commit.md
                git add commit.md -f >/dev/null
                git commit --date="${date1}T${time3}±05:00" -m "${time3} on ${date1}" >/dev/null
        done

        echo $date1
        a=`date -d "${a} +1 day" +%Y%m%d)`
done
git push origin master -f>/dev/null
echo "Successfully,end"
