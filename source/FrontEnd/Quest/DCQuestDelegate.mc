import Toybox.WatchUi;
import Toybox.Lang;

class DCQuestDelegate extends WatchUi.Menu2InputDelegate {
    private var questGiver as QuestGiver;

	public static function pushMenu(questGiver as QuestGiver) as Void {
		var menu = new WatchUi.Menu2({:title=>"Quests"});
        if ($.Quests.getActiveQuests().size() < $.Quests.MAX_ACTIVE) {
            menu.addItem(new WatchUi.MenuItem("Request Quest", "Receive a random quest", :newquest, null));
        }
        menu.addItem(new WatchUi.MenuItem("View Quests", "See progress", :progress, null));
        if ($.Quests.hasCompletedQuests()) {
            menu.addItem(new WatchUi.MenuItem("Claim Rewards", "Turn in completed quests", :claim, null));
        }
        menu.addItem(new WatchUi.MenuItem("Talk", "Chat", :talk, null));
        WatchUi.pushView(menu, new DCQuestDelegate(questGiver), WatchUi.SLIDE_UP);
	}

    function initialize(questGiver as QuestGiver) {
        Menu2InputDelegate.initialize();
        self.questGiver = questGiver;
    }

    function onSelect(item as MenuItem) as Void {
        var action = item.getId() as Symbol;
        switch (action) {
            case :newquest:
                offerQuestChoices();
                break;
            case :progress:
                showProgress();
                break;
            case :claim:
                claimRewards();
                break;
            case :talk:
                WatchUi.pushView(new TextView(questGiver.getDialog()), new TextDelegate(), WatchUi.SLIDE_UP);
                break;
        }
    }

    function offerQuestChoices() as Void {
        if (self.questGiver.quest_requested) {
            WatchUi.showToast("You have already requested a quest from this quest giver", {});
            return;
        }
        if ($.Quests.getActiveQuests().size() >= $.Quests.MAX_ACTIVE) {
            WatchUi.showToast("Quest log is full", {});
            return;
        }
        var choices = questGiver.offers;
        if (choices.size() == 0) {
            choices = $.Quests.buildQuestChoices($.Game.depth, 3);
            questGiver.offers = choices;
        }
        if (choices.size() == 0) {
            WatchUi.showToast("No quests available", {});
            return;
        }
        var menu = new WatchUi.Menu2({:title=>"Choose a Quest"});
        for (var i = 0; i < choices.size(); i++) {
            var quest = choices[i];
            var subtitle = quest.description + " | Reward " + quest.getRewardLabel();
            menu.addItem(new WatchUi.MenuItem(quest.getTitle(), subtitle, quest, null));
        }
        WatchUi.pushView(menu, new DCQuestOfferDelegate(self.questGiver, choices), WatchUi.SLIDE_UP);
    }

    function showProgress() as Void {
        $.Quests.updateFitnessProgress();
        var quests = $.Quests.getActiveQuests();
        if (quests.size() == 0) {
            WatchUi.showToast("No active quests", {});
            return;
        }
        var menu = new WatchUi.Menu2({:title=>"Active Quests"});
        for (var i = 0; i < quests.size(); i++) {
            var quest = quests[i];
            var subtitle = quest.getProgressLabel() + " | Reward " + quest.getRewardLabel();
            if (quest.completed) {
                subtitle = "Ready to claim" + " | Reward " + quest.getRewardLabel();
            }
            menu.addItem(new WatchUi.MenuItem(quest.getTitle(), subtitle, quest, null));
        }
        WatchUi.pushView(menu, new DCQuestListDelegate(), WatchUi.SLIDE_LEFT);
    }

    function claimRewards() as Void {
        var player = getApp().getPlayer();
        var result = $.Quests.claimCompleted(player);
        if (result[:claimed] == 0) {
            WatchUi.showToast("No rewards to claim", {});
            return;
        }
        var message = "Claimed " + result[:claimed] + " quest" + (result[:claimed] > 1 ? "s" : "") +
            "\nGold: " + result[:gold].format("%.0f") + "\nXP: " + result[:exp].format("%.0f");
        WatchUi.pushView(new TextView(message), new TextDelegate(), WatchUi.SLIDE_UP);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

class DCQuestListDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        // No action on selection; list is informational
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }
}

class DCQuestOfferDelegate extends WatchUi.Menu2InputDelegate {
    private var questGiver as QuestGiver;

    function initialize(questGiver as QuestGiver, offers as Array<Quest>) {
        Menu2InputDelegate.initialize();
        self.questGiver = questGiver;
    }

    function onSelect(item as MenuItem) as Void {
        var quest = item.getId() as Quest;
        var prompt = quest.getTitle() + "\n" + quest.description + "\nReward: " + quest.getRewardLabel();
        var dialog = new WatchUi.Confirmation(prompt);
        WatchUi.pushView(dialog, new DCQuestAcceptConfirmDelegate(questGiver, quest), WatchUi.SLIDE_UP);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

class DCQuestAcceptConfirmDelegate extends WatchUi.ConfirmationDelegate {
    private var questGiver as QuestGiver;
    private var quest as Quest;

    function initialize(questGiver as QuestGiver, quest as Quest) {
        ConfirmationDelegate.initialize();
        self.questGiver = questGiver;
        self.quest = quest;
    }

    function onResponse(value as Confirm) as Boolean {
        if (value == WatchUi.CONFIRM_YES) {
            var accepted = $.Quests.acceptQuest(quest);
            if (accepted == null) {
                WatchUi.showToast("Could not accept quest", {});
                return true;
            }
            questGiver.quest_requested = true;
            questGiver.offers = [];
            var message = accepted.getTitle() + "\n" + accepted.description + "\nReward: " + accepted.getRewardLabel();
            // Remove the offer list before showing the acceptance message.
            WatchUi.popView(WatchUi.SLIDE_DOWN);
			WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.pushView(new TextView(message), new TextDelegate(), WatchUi.SLIDE_UP);
            $.Log.log("Accepted quest: " + accepted.getTitle());
			// Add Empty View so that this one is popped
			WatchUi.pushView(new EmptyView(), null, WatchUi.SLIDE_UP);
        }
        return true;
    }
}
