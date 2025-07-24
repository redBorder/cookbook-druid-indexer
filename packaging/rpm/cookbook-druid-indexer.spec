%undefine __brp_mangle_shebangs

Name: cookbook-druid-indexer
Version: %{__version}
Release: %{__release}%{?dist}
BuildArch: noarch

License: AGPL 3.0
URL: https://github.com/redBorder/cookbook-druid-indexer
Source0: %{name}-%{version}.tar.gz

Requires: dos2unix

Summary: druid-indexer cookbook to install and configure it in redborder environments
%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}/var/chef/cookbooks/rb-druid-indexer
cp -f -r  resources/* %{buildroot}/var/chef/cookbooks/rb-druid-indexer/
chmod -R 0755 %{buildroot}/var/chef/cookbooks/rb-druid-indexer
install -D -m 0644 README.md %{buildroot}/var/chef/cookbooks/rb-druid-indexer/README.md

%pre

%post
/usr/lib/redborder/bin/rb_rubywrapper.sh -c
case "$1" in
  1)
    # This is an initial install.
    :
  ;;
  2)
    # This is an upgrade.
    su - -s /bin/bash -c 'source /etc/profile && rvm gemset use default && env knife cookbook upload rb-druid-indexer'
  ;;
esac

%files
%defattr(0644,root,root)
%attr(0755,root,root)
/var/chef/cookbooks/rb-druid-indexer
%defattr(0644,root,root)
/var/chef/cookbooks/rb-druid-indexer/README.md

%doc

%changelog
* Thu Feb 27 2025 Miguel Álvarez <malvarez@redborder.com> - 
- First version