#!/bin/bash

if [ ! -d  /srv/web/developer.fedoraproject.org/.git ]
then
    /usr/bin/git clone -q https://github.com/developer-portal/developer.fedoraproject.org.git /srv/web/developer.fedoraproject.org
fi

cd /srv/web/developer.fedoraproject.org

/usr/bin/git clean -q -fdx || exit 1
/usr/bin/git reset -q --hard || exit 1
/usr/bin/git checkout -q release || exit 1
/usr/bin/git pull -q --ff-only || exit 1

# Now we update the blog content 
/usr/local/bin/rss.py /srv/web/developer.fedoraproject.org/index.html
