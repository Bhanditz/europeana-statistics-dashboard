class Constants

  #Accounts
  ACC_U = "User" #Constants::ACC_U

  #Regex
  EMAIL = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i  #Constants::EMAIL
  PASSWORD = /^(?=.*\d)(?=.*([a-z]|[A-Z]))([\x20-\x7E]){8,}$/  #Constants::PASSWORD
  GIT_URL = /(^git@)(.+)(:)(.+)(\/)(.+)(.git$)/ #Constants::GIT_URL
  URL = URI::regexp(%w(http https))  #Constants::URL

  #SUDO
  #Owner, Collaborator, Viewer
  SUDO_111 = [true, true, true]
  SUDO_011 = [false, true, true]
  SUDO_001 = [false, false, true]

  #Permissions
  ROLE_C = "Collaborator" #Constants::ROLE_C
  ROLE_O = "Owner" #Constants::ROLE_O
  STATUS_A = "Accepted" #Constants::STATUS_A
  STATUS_I = "Invited" #Constants::STATUS_I

  #VERSION
  RUMI_VERSION = "1.0"

  #Constants::STUPID_PASSWORDS
  STUPID_PASSWORDS = ["password", "123456", "12345678", "abc123", "qwerty", "monkey", "letmein", "dragon", "111111", "baseball", "iloveyou", "trustno1", "1234567", "sunshine", "master", "123123", "welcome", "shadow", "ashley", "football", "jesus", "michael", "ninja", "mustang", "password1", "123456789", "admin", "princess", "azerty", "photoshop", "000000", "1234567890"]

  #Constants::STUPID_USERNAMES
  STUPID_USERNAMES = ["about","account","add","admin","api","app","apps","archive","archives","auth","better","billing","blog","cache","cdn","changelog","codereview","compare","config","connect","contact","create","delete","dev","direct_messages","downloads","edit","email","enterprise","faq","favorites","feed","feeds","follow","followers","following","ftp","gist","help","home","hosting","imap","invitations","invite","jobs","lists","log","login","logout","logs","mail","map","maps","master","messages","mine","news","next","oauth","oauth_clients","openid","organizations","plans","pop","popular","privacy","production","projects","register","remove","replies","rss","rsync","save","search","security","sessions","settings","sftp","shop","signup","sitemap","ssh","ssl","staging","status","stories","styleguide","subscribe","support","terms","tour","translations","trends","unfollow","unsubscribe","url","user","widget","widgets","wiki","www","xfn","xmpp", "404","account","accounts","admin","admins","administrator","administrators","billing","block","blog","bot","bots","bug","bugs","calendar","careers","chat","checkuser","client","clients","comment","comments","contract","contracts","create","customer","customers","customersupport","dev","development","download","downloads","ecommerce","enquiries","error","errors","event","events","faq","feedback","flock","form","forms","forum","github","help","herd","home","info","internal","invoice","invoices","issue","issues","job","jobs","log","mail","manual","new","news","office","press","print","recruit","script","scripts","service","services","shepherd","shepherdess","staff","staging","support","sysop","team","training","trainings","troll","version","video","videos","webmail","wiki","test","testing","tester","beta","mobile","list","site","friend","member"]

end