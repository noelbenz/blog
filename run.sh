
if [ -e "bin/Blog" ]
then
	rm -f bin/Blog
fi

gdc -o bin/Blog main.d blog.d

bin/Blog

