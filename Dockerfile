FROM atsnngs/middleman-blog

ADD Gemfile Gemfile.lock .
RUN bundle install
