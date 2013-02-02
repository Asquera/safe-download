class tomcat7::jpackage_repo {
  yumrepo { "jpackage":
    descr => "JPackage project",
    baseurl => "http://mirrors.dotsrc.org/jpackage/6.0/generic/free/",
    enabled => 1,
    gpgcheck => 1,
    gpgkey => "http://www.jpackage.org/jpackage.asc",
  }
}
