Name: cookbook-example
Version: %{__version}
Release: %{__release}%{?dist}
BuildArch: noarch
Summary: Example cookbook to install and configure it in redborder environments

License: AGPL 3.0
URL: https://github.com/redBorder/cookbook-example
Source0: %{name}-%{version}.tar.gz

%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}/var/chef/cookbooks/example
cp -f -r  resources/* %{buildroot}/var/chef/cookbooks/example
chmod -R 0755 %{buildroot}/var/chef/cookbooks/example
install -D -m 0644 README.md %{buildroot}/var/chef/cookbooks/example/README.md

%pre

%post

%files
%defattr(0755,root,root)
/var/chef/cookbooks/example
%defattr(0644,root,root)
/var/chef/cookbooks/example/README.md


%doc

%changelog
* Tue Oct 18 2016 Your name <yourname@redborder.com> - 1.0.0-1
- first spec version
