 FROM ubuntu
 RUN apt-get -y update && apt-get install -y ruby
 RUN apt-get install ruby-dev -y
 RUN apt-get install build-essential -y
 RUN apt-get install libsqlite3-dev -y
 RUN apt-get install libssl-dev -y
 RUN gem install tweetstream
 RUN gem install sequel
 RUN gem install sqlite3
 ADD *.rb ./
 ADD migrations/* migrations/
 CMD ruby migrations/* 
 ENTRYPOINT /bin/bash -c "ruby tws.rb"
 ENV TERM /bin/bash
