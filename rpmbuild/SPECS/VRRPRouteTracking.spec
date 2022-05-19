Summary: VRRPRouteTracking
Name: VRRPRouteTracking
Version: 0.2.1
Release: 3
License: Arista Networks
Group: EOS/Extension
Source0: %{name}-%{version}-%{release}.tar
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}.tar
BuildArch: noarch

%description
This EOS SDK script will monitor IP Routes and update VRRP Priority levels.

%prep
%setup -q -n source

%build

%install
mkdir -p $RPM_BUILD_ROOT/usr/bin
cp VRRPRouteTracking $RPM_BUILD_ROOT/usr/bin/

%files
%defattr(-,root,root,-)
/usr/bin/VRRPRouteTracking
%attr(0755,root,root) /usr/bin/VRRPRouteTracking
