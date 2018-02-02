Name: cookbook-f2k
Version: %{__version}
Release: %{__release}%{?dist}
BuildArch: noarch
Summary: cookbook to deploy f2k in redborder environments

License: AGPL 3.0
URL: https://github.com/redBorder/cookbook-example
Source0: %{name}-%{version}.tar.gz

%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}/var/chef/cookbooks/f2k
cp -f -r  resources/* %{buildroot}/var/chef/cookbooks/f2k
chmod -R 0755 %{buildroot}/var/chef/cookbooks/f2k
install -D -m 0644 README.md %{buildroot}/var/chef/cookbooks/f2k/README.md

%pre

%post
case "$1" in
  1)
    # This is an initial install.
    :
  ;;
  2)
    # This is an upgrade.
    su - -s /bin/bash -c 'source /etc/profile && rvm gemset use default && env knife cookbook upload f2k'
  ;;
esac

%files
%defattr(0755,root,root)
/var/chef/cookbooks/f2k
%defattr(0644,root,root)
/var/chef/cookbooks/f2k/README.md


%doc

%changelog
* Mon Jan 16 2017 Alberto Rodríguez <arodriguez@redborder.com> - 0.0.1-1
- first spec version
