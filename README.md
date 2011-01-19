Paper Management System
========================

Installation
------------
1. `git clone sms.git`
2. `gem install rails -v 1.2.5` or `rake rails:freeze:edge TAG=rel_1-2-5`
3. `gem install ferret -v 0.11.5` (download `ferret-0.11.5-mswin32.gem` and install local for windows)
4. edit `config/database.yml` if necessary
5. `rake db:migrate RAILS_ENV=production`
6. `ruby script/server -e production`

Enjoy yourself!

Admin Usage
-----------
1. Signup admin (first time only)
   > http://127.0.0.1:3000/admin_account/signup
2. Login
   > http://127.0.0.1:3000/
3. Add some users

Common Usage
------------
1. Login (after admin added users)
   > http://127.0.0.1:3000/
2. Contribute papers
3. To Read, Reading or Finished
4. Note and Discuss on papers
5. Tag papers
6. Search papers

Screenshots
-----------
* pics in `./public/screenshots`
