# == Class zookeeper::repo
#
# This class manages yum repository for Zookeeper packages
#

class zookeeper::repo(
  $source = undef
) {

  if $source {
    case $::osfamily {
      'redhat': {
        case $source {
          undef: {} #nothing to do
          'cloudera': {
            $cdhver = '4'
            $osrel = $::operatingsystemmajrelease

            case $::hardwaremodel {
              'i386', 'x86_64': {
                $repourl = "http://archive.cloudera.com/cdh${cdhver}/redhat/6/${::hardwaremodel}/cdh/cloudera-cdh${cdhver}.repo"
              }
            }
            default: {
              fail { "Yum repository '${source}' is not supported for architecture ${hardwaremodel}": }
            }
            case $osrel {
              '6': {
                exec{ 'retrieve_clouderakey':
                  command => "/usr/bin/curl -q http://archive.cloudera.com/cdh${cdhver}/redhat/6/${::hardwaremodel}/cdh/RPM-GPG-KEY-cloudera -O /etc/pki/rpm-gpg/RPM-GPG-KEY-cloudera",
                  creates => '/etc/pki/rpm-gpg/RPM-GPG-KEY-cloudera',
                }

                file{ '/etc/pki/rpm-gpg/RPM-GPG-KEY-cloudera':
                  mode => 0755,
                  require => Exec["retrieve_clouderakey"],
                }

                yumrepo { "cloudera-cdh${cdhver}":
                  ensure   => present,
                  descr => "Cloudera's Distribution for Hadoop, Version ${cdhver}"
                  baseurl => "http://archive.cloudera.com/cdh${cdhver}/redhat/6/${::hardwaremodel}/cdh/${cdhver}/"
                  gpgkey => "http://archive.cloudera.com/cdh${cdhver}/redhat/6/${::hardwaremodel}/cdh/RPM-GPG-KEY-cloudera"
                  gpgcheck => 'Yes'
                }
              }
              default: {
                fail { "Yum repository '${source}' is not supported for redhat version ${::osrel}": }
              }
            }
          }
        }
      }
      default: {
        fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
      }
    }
  }
}
