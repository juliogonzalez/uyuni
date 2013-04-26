Name:           perl-Net-INET6Glue
Version:        0.5
Release:        3%{?dist}
Summary:        Make common modules IPv6 ready by hotpatching
License:        GPL+ or Artistic
Group:          Development/Libraries
URL:            http://search.cpan.org/dist/Net-INET6Glue/
Source0:        http://www.cpan.org/modules/by-module/Net/Net-INET6Glue-%{version}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch:      noarch
BuildRequires:  perl(ExtUtils::MakeMaker)
%if 0%{?rhel} == 5
BuildRequires:  perl(IO::Socket::INET6)
Requires:       perl(IO::Socket::INET6)
%else
BuildRequires:  perl(IO::Socket::INET6) >= 2.54
Requires:       perl(IO::Socket::INET6) >= 2.54
%endif
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))

%description
Net::INET6Glue is a collection of modules to make common modules IPv6 ready
by hotpatching them.

%prep
%setup -q -n Net-INET6Glue-%{version}

%build
%{__perl} Makefile.PL INSTALLDIRS=vendor
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT

make pure_install PERL_INSTALL_ROOT=$RPM_BUILD_ROOT

find $RPM_BUILD_ROOT -type f -name .packlist -exec rm -f {} \;
find $RPM_BUILD_ROOT -depth -type d -exec rmdir {} 2>/dev/null \;

%{_fixperms} $RPM_BUILD_ROOT/*

%check
make test

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc Changes COPYRIGHT README
%{perl_vendorlib}/*
%{_mandir}/man3/*

%changelog
* Mon Apr 22 2013 Jan Pazdziora 0.5-3
- Fixing build.py.props for the new package.

* Fri Apr 19 2013 Jan Pazdziora 0.5-2
- Relax the IO::Socket::INET6 version requirement on RHEL 5.

* Fri Apr 19 2013 Jan Pazdziora 0.5-1
- Specfile autogenerated by cpanspec 1.78.
