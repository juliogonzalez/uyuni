# Copyright (c) 2018 SUSE LLC
# Licensed under the terms of the MIT license.

Feature: Action chain tests for salt minions
 
 Scenario: [minion-action-chain] Pre-requisite: downgrade repo to lower version
    Given I am authorized as "admin" with password "admin"
    When I run "zypper -n mr -e Devel_Galaxy_BuildRepo" on "sle-minion"
    And I run "zypper -n rm andromeda-dummy" on "sle-minion" without error control
    And I run "zypper -n rm virgo-dummy" on "sle-minion" without error control
    And I run "zypper -n in milkyway-dummy" on "sle-minion" without error control
    And I run "zypper -n in --oldpackage andromeda-dummy-1.0-4.1" on "sle-minion"
    And I run "zypper -n ref" on "sle-minion"
    And I follow "Admin"
    And I follow "Task Schedules"
    And I follow "Task Schedules"
    And I follow "errata-cache-default"
    And I follow "errata-cache-bunch"
    And I click on "Single Run Schedule"
    Then I should see a "bunch was scheduled" text
    And I reload the page
    And I reload the page until it does contain a "FINISHED" text in the table first row

  Scenario: [minion-action-chain] Add a package installation to an action chain
    Given I am on the Systems overview page of this "sle-minion"
    When I follow "Software" in the content area
    And I follow "Install New Packages" in the content area
    And I check "virgo-dummy" in the list
    And I click on "Install Selected Packages"
    And I check radio button "schedule-by-action-chain"
    And I click on "Confirm"
    Then I should see a "Action has been successfully added to the Action Chain" text

  Scenario: [minion-action-chain] Add a remote command to the action chain
    Given I am on the Systems overview page of this "sle-minion"
    When I follow "Remote Command"
    And I enter as remote command this script in
      """
      #!/bin/bash
      touch /root/12345
      """
    And I check radio button "schedule-by-action-chain"
    And I click on "Schedule"
    Then I should see a "Action has been successfully added to the Action Chain" text

  Scenario: [minion-action-chain] Add a patch installation to the action chain
    Given I am on the Systems overview page of this "sle-minion"
    When I follow "Software" in the content area
    And I follow "Patches" in the content area
    And I check "andromeda-dummy-6789" in the list
    And I click on "Apply Patches"
    And I check radio button "schedule-by-action-chain"
    And I click on "Confirm"
    Then I should see a "Action has been successfully added to the Action Chain" text

  Scenario: [minion-action-chain] Add a package removal to the action chain
    Given I am on the Systems overview page of this "sle-minion"
    When I follow "Software" in the content area
    And I follow "List / Remove" in the content area
    And I enter "milkyway-dummy" in the css "input[placeholder='Filter by Package Name: ']"
    And I click on the css "button.spacewalk-button-filter"
    And I check "milkyway-dummy" in the list
    And I click on "Remove Packages"
    And I check radio button "schedule-by-action-chain"
    And I click on "Confirm"
    Then I should see a "Action has been successfully added to the Action Chain" text

  Scenario: [minion-action-chain] Create a configuration channel for testing action chains
    Given I am authorized as "admin" with password "admin"
    And I follow "Home" in the left menu
    And I follow "Configuration" in the left menu
    And I follow "Configuration Channels" in the left menu
    When I follow "Create Config Channel"
    And I enter "Action Chain Channel" as "cofName"
    And I enter "actionchainchannel" as "cofLabel"
    And I enter "This is a test channel" as "cofDescription"
    And I click on "Create Config Channel"
    Then I should see a "Action Chain Channel" text

  Scenario: [minion-action-chain] Add a configuration file to configuration channel
    Given I am authorized as "admin" with password "admin"
    And I follow "Home" in the left menu
    And I follow "Configuration" in the left menu
    And I follow "Configuration Channels" in the left menu
    When I follow "Action Chain Channel"
    And I follow "Create Configuration File or Directory"
    And I enter "/etc/action-chain.cnf" as "cffPath"
    And I enter "Testchain=YES_PLEASE" in the editor
    And I click on "Create Configuration File"
    Then I should see a "Revision 1 of /etc/action-chain.cnf from channel Action Chain Channel" text
    And I should see a "Update Configuration File" button

  Scenario: [minion-action-chain] Subscribe system to configuration channel
    Given I am authorized as "admin" with password "admin"
    And I follow "Home" in the left menu
    When I follow "Systems" in the left menu
    And I follow "Overview" in the left menu
    And I follow this "sle-minion" link
    When I follow "Configuration" in the content area
    And I follow "Manage Configuration Channels" in the content area
    And I follow first "Subscribe to Channels" in the content area
    And I check "Action Chain Channel" in the list
    And I click on "Continue"
    And I click on "Update Channel Rankings"
    Then I should see a "Channel Subscriptions successfully changed for" text

  Scenario: [minion-action-chain] Add a configuration file deployment to the action chain
    Given I am authorized as "admin" with password "admin"
    And I follow "Home" in the left menu
    And I follow "Configuration" in the left menu
    And I follow "Configuration Channels" in the left menu
    And I follow "Action Chain Channel"
    And I follow "Deploy Files" in the content area
    And I click on "Deploy All Files"
    And I check the "sle-minion" client
    And I click on "Confirm & Deploy to Selected Systems"
    And I check radio button "schedule-by-action-chain"
    And I click on "Deploy Files to Selected Systems"
    Then I should see a "Action has been successfully added to the Action Chain" text

  Scenario: Add apply highstate to minion action-chain
    Given I am on the Systems overview page of this "sle-minion"
     And I follow "States" in the content area
     And I check radio button "schedule-by-action-chain"
     And I click on "Apply Highstate"

  Scenario: [minion-action-chain]  Add a reboot action to the action chain
    Given I am on the Systems overview page of this "sle-minion"
    When I follow first "Schedule System Reboot"
    And I check radio button "schedule-by-action-chain"
    And I click on "Reboot system"
    Then I should see a "Action has been successfully added to the Action Chain" text

  Scenario: [minion-action-chain] Verify the action chain list
    Given I am on the Systems overview page of this "sle-minion"
    When I follow "Schedule"
    And I follow "Action Chains"
    And I follow "new action chain"
    And I should see a "1. Install or update virgo-dummy on 1 system" text
    And I should see a "2. Run a remote command on 1 system" text
    And I should see a "3. Apply patch(es) andromeda-dummy-6789 on 1 system" text
    And I should see a "4. Remove milkyway-dummy from 1 system" text
    And I should see a text like "5. Deploy.*/etc/action-chain.cnf.*to 1 system"
    And I should see a "6. Apply Highstate" text
    And I should see a "7. Reboot system" text

  Scenario: [minion-action-chain] Execute the action chain from the web UI
   Given I am on the Systems overview page of this "sle-minion"
   When I follow "Schedule"
   And I follow "Action Chains"
   And I follow "new action chain"
   Then I click on "Save and Schedule"
   And I should see a "Action Chain new action chain has been scheduled for execution." text

  Scenario: [minion-action-chain] Check that a different user cannot see the action chain
    Given I am authorized as "testing" with password "testing"
    When I follow "Schedule"
    And I follow "Action Chains"
    Then I should not see a "new action chain" link

  Scenario: [minion-action-chain] Add a remote command to the new action chain
    Given I am on the Systems overview page of this "sle-minion"
    When I follow "Remote Command"
    And I enter as remote command this script in
      """
      #!/bin/bash
      uptime
      """
    And I check radio button "schedule-by-action-chain"
    And I click on "Schedule"
    Then I should see a "Action has been successfully added to the Action Chain" text

  Scenario: [minion-action-chain] Delete the action chain
     Given I am authorized as "admin" with password "admin"
     Then I follow "Schedule"
     And I follow "Action Chains"
     And I follow "new action chain"
     And I follow "delete action chain" in the content area
     Then I click on "Delete"

  Scenario: Add an action-chain using system-set-manager for trad-client and sle-minion
   Given I am authorized as "admin" with password "admin"
    And I run "zypper -n rm andromeda-dummy" on "sle-client" without error control
    And I run "zypper -n rm andromeda-dummy" on "sle-minion" without error control
    When I am on the System Overview page
    And I check the "sle-minion" client
    And I check the "sle-client" client
    And I am on System Set Manager Overview
    And I follow "Install" in the content area
    And I follow "Test-Channel-x86_64" in the content area                                       
    And I enter "andromeda-dummy" in the css "input[placeholder='Filter by Package Name: ']"
    And I click on the css "button.spacewalk-button-filter"
    And I check "andromeda-dummy" in the list
    And I click on "Install Selected Packages"
    Then I should see "sle-minion" hostname
    Then I should see "sle-client" hostname
    And I check radio button "schedule-by-action-chain"
    And I click on "Confirm"
    Then I should see a "Package installations are being scheduled" text

  Scenario: Verify that action-chains are executed with success
    Given I wait until event "Apply Highstate" is completed for "sle-minion"
    And I wait until event "System reboot" is completed for "sle-minion"
    And "milkyway-dummy" should not be installed on "sle-minion"

  Scenario: Verify action-chain for 2 system-set-manager (traditional and sle minion)
    Given I am on the Systems overview page of this "sle-minion"
    When I follow "Schedule"
    And I follow "Action Chains"
    And I follow "new action chain"
    And I should see a "1. Install or update andromeda-dummy on 2 systems" text
    Then I click on "Save and Schedule"
    And I should see a "Action Chain new action chain has been scheduled for execution." text

  Scenario: Cleanup: remove system from configuration channel
    Given I am authorized as "admin" with password "admin"
    And I follow "Home" in the left menu
    When I follow "Configuration" in the left menu
    And I follow "Configuration Channels" in the left menu
    And I follow "Action Chain Channel"
    And I follow "Systems" in the content area
    And I check the "sle-minion" client
    And I click on "Unsubscribe systems"
    Then I should see a "Successfully unsubscribed 1 system(s)." text

  Scenario: Cleanup: remove configuration channel
    Given I am authorized as "admin" with password "admin"
    And I follow "Home" in the left menu
    And I follow "Configuration" in the left menu
    And I follow "Configuration Channels" in the left menu
    And I follow "Action Chain Channel"
    And I follow "Delete Channel"
    And I click on "Delete Config Channel"

  Scenario: Cleanup: remove packages and repository used in action chain
    When I run "zypper -n rm andromeda-dummy" on "sle-minion" without error control
    And I run "zypper -n rm virgo-dummy" on "sle-minion" without error control
    And I run "zypper -n rm milkyway-dummy" on "sle-minion" without error control
    And I run "zypper -n mr -d Devel_Galaxy_BuildRepo" on "sle-minion" without error control
    And I run "rm -f /etc/action-chain.cnf" on "sle-minion" without error control
