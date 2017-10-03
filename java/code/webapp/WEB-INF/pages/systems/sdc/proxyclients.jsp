<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://rhn.redhat.com/rhn" prefix="rhn" %>
<%@ taglib uri="http://rhn.redhat.com/tags/list" prefix="rl" %>
<%@ taglib uri="http://struts.apache.org/tags-bean" prefix="bean" %>
<%@ taglib uri="http://struts.apache.org/tags-html" prefix="html" %>

<html:html>
  <body>
    <%@ include file="/WEB-INF/pages/common/fragments/systems/system-header.jspf" %>

    <h2><rhn:icon type="header-proxy" /><bean:message key="sdc.details.proxyclients.header"/></h2>

    <c:choose>
      <c:when test="${requestScope.version != null}">
        <p><bean:message key="sdc.details.proxy.licensed" arg0="${requestScope.version}" /></p>
      </c:when>
      <c:otherwise>
        <p><bean:message key="sdc.details.proxy.unlicensed" /></p>
      </c:otherwise>
    </c:choose>
    <rl:listset name="systemListSet" legend="system">

      <c:set var="noAddToSsm" value="1" />
      <c:choose>
      <c:when test = "${empty notSelectable}">
              <c:set var="namestyle" value = ""/>
      </c:when>
      <c:otherwise>
              <c:set var="namestyle" value = "first-column"/>
      </c:otherwise>
      </c:choose>

              <rl:list
                      dataset="pageList"
                      name="systemList"
                      emptykey="nosystems.message"
                      alphabarcolumn="name"
                      >

              <rl:decorator name="ElaborationDecorator"/>
              <rl:decorator name="SystemIconDecorator"/>
              <c:if test = "${empty noAddToSsm}">
                <rl:decorator name="AddToSsmDecorator" />
              </c:if>

                      <c:if test = "${empty notSelectable}">
                          <rl:selectablecolumn value="${current.id}"
                                                              selected="${current.selected}"
                                                              disabled="${not current.selectable}"/>
                      </c:if>
                      <!-- Name Column -->
                      <rl:column sortable="true"
                                         bound="false"
                                 headerkey="systemlist.jsp.system"
                                 sortattr="name"
                                 defaultsort="asc"
                                 styleclass="${namestyle}">
                              <%@ include file="/WEB-INF/pages/common/fragments/systems/system_list_fragment.jspf" %>
                      </rl:column>


                      <c:if test = "${empty extraPackagesMode and empty noUpdates}">
                      <!--Updates Column -->
                      <rl:column sortable="false"
                                         bound="false"
                                 headerkey="systemlist.jsp.status"
                                 styleclass="center"
                                      headerclass="thin-column">
                            <c:out value="${current.statusDisplay}" escapeXml="false"/>
                      </rl:column>
                      </c:if>

                      <c:if test = "${empty noErrata and empty extraPackagesMode}">
                      <!-- errata Column -->
                      <rl:column sortable="false"
                                         bound="false"
                                 headerkey="systemlist.jsp.errata"
                                 styleclass="center"
                                 headerclass="thin-column">
                              <c:choose>
                                      <c:when test="${(current.totalErrataCount) == 0}">
                                              <c:out value="0" />
                                      </c:when>
                                      <c:otherwise>
                                                      <c:out value="<a href=\"/rhn/systems/details/ErrataList.do?sid=${current.id}\">${current.totalErrataCount}</a>" escapeXml="false" />
                                      </c:otherwise>
                              </c:choose>
                      </rl:column>
                  </c:if>
                 <c:if test = "${empty noPackages and empty extraPackagesMode}">
                      <!-- Packages Column -->
                      <rl:column sortable="false"
                                         bound="false"
                                 headerkey="systemlist.jsp.packages"
                                 styleclass="center"
                                 headerclass="thin-column">

                              <c:choose>
                                      <c:when test="${(current.outdatedPackages) == 0}">
                                              <c:out value="0" />
                                      </c:when>
                                      <c:otherwise>
                                                      <c:out value="<a href=\"/rhn/systems/details/packages/UpgradableList.do?sid=${current.id}\">${current.outdatedPackages}</a>" escapeXml="false" />
                                      </c:otherwise>
                              </c:choose>
                      </rl:column>
                      </c:if>
                     <!-- Extra packages column -->
                     <c:if test = "${extraPackagesMode}">
                     <rl:column sortable="false" bound="false" headerkey="systemlist.jsp.packages" styleclass="center" headerclass="thin-column">
      <c:out value="<a href='/rhn/systems/details/packages/ExtraPackagesList.do?sid=${current.id}'>${current.extraPkgCount}</a>" escapeXml="false" />
                     </rl:column>
                     </c:if>

                      <c:if test = "${empty noConfigFiles and empty extraPackagesMode}">
                              <rl:column sortable="false"
                                         bound="false"
                                         headerkey="systemlist.jsp.configfiles"
                                         styleclass="center"
                                         headerclass="thin-column">
                                      <c:choose>
                                              <c:when test="${(current.configFilesWithDifferences) == 0}">
                                                      <c:out value="0" />
                                              </c:when>
                                              <c:otherwise>
                                                      <c:out value="<a href='/rhn/systems/details/configuration/Overview.do?sid=${current.id}'>${current.configFilesWithDifferences}</a>" escapeXml="false" />
                                              </c:otherwise>
                                      </c:choose>
                              </rl:column>
                      </c:if>
                      <c:if test="${empty extraPackagesMode and empty noCrashes}">
                          <rl:column sortable="false"
                                     bound="false"
                                     headerkey="systemlist.jsp.crashes"
                                     styleclass="center"
                                     headerclass="thin-column">
                              <c:choose>
                                  <c:when test="${current.totalCrashCount == null}">
                                      <bean:message key="none.message"/>
                                  </c:when>
                                  <c:otherwise>
                                      <a href="/rhn/systems/details/SoftwareCrashes.do?sid=${current.id}">
                                      <c:out value="${current.totalCrashCount}" escapeXml="false"/>
                                      </a>
                                  </c:otherwise>
                              </c:choose>
                          </rl:column>
                      </c:if>

                      <c:if test = "${not empty showLastCheckin}">
                              <rl:column sortable="false"
                                                  attr="lastCheckin"
                                                  bound="false"
                                              headerkey="systemlist.jsp.last_checked_in">
                      <rhn:formatDate humanStyle="from" value="${current.lastCheckinDate}"
                                    type="both" dateStyle="short" timeStyle="long"/>
                  </rl:column>
                      </c:if>

          <c:if test = "${not empty showLastCheckinSort}">
              <rl:column sortable="true"
                        attr="lastCheckin"
                        sortattr="lastCheckinDate"
                        bound="false"
                        headerkey="systemlist.jsp.last_checked_in">
                  <rhn:formatDate humanStyle="from" value="${current.lastCheckinDate}"
                                 type="both" dateStyle="short" timeStyle="long"/>
              </rl:column>
          </c:if>

                      <!-- Base Channel Column -->
                      <rl:column sortable="false"
                                         bound="false"
                                 headerkey="systemlist.jsp.channel"  >
                 <%@ include file="/WEB-INF/pages/common/fragments/channel/channel_list_fragment.jspf" %>
                      </rl:column>

                      <!-- Entitlement Column -->
                      <c:if test="${empty extraPackagesMode}">
                      <rl:column sortable="false"
                                         bound="false"
                                 headerkey="systemlist.jsp.entitlement">
                            <c:out value="${current.entitlementLevel}" escapeXml="false"/>
                      </rl:column>
                      </c:if>



              </rl:list>
              <c:if test = "${empty noCsv}">
              <rl:csv dataset="pageList"
                      name="systemList"
                      exportColumns="name,id,securityErrata,bugErrata,enhancementErrata,outdatedPackages,lastCheckin,entitlementLevel,channelLabels"/>
              </c:if>
          <rhn:csrf />
              <rhn:submitted/>
    </rl:listset>

  </body>
</html:html>
