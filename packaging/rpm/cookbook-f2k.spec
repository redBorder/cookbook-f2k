Name: cookbook-f2k
Version: %{__version}
Release: %{__release}%{?dist}.1
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
* Thu Sep 26 2023 Miguel Negrón <manegron@redborder.com> - 0.0.8-1
- Install f2k before user creation (by Eduardo)
* Thu May 25 2023 Luis J. Blanco <ljblanco@redborder.com> - 0.0.7-1
- parent_id removed from sensor info. Nodes are self aware of either manager or proxy
* Fri Jan 07 2022 David Vanhoucke <dvanhoucke@redborder.com> - 0.0.5-1
- change register to consul
* Wed Oct 06 2021 Javier Rodriguez <javiercrg@redborder.com> - 0.0.2-1
- Added creation template directory

* Mon Jan 16 2017 Alberto Rodríguez <arodriguez@redborder.com> - 0.0.1-1
- first spec version
