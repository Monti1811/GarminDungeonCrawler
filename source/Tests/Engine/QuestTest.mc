import Toybox.Lang;
import Toybox.Test;

(:test)
function questInitializeWithOptions(logger as Test.Logger) as Boolean {
    var quest = new Quest({
        :id => 1,
        :type => KILL_ENEMIES,
        :target => 10,
        :progress => 3,
        :reward_gold => 50,
        :reward_exp => 25,
        :description => "Slay 10 monsters.",
        :completed => false
    });
    Test.assertEqual(quest.id, 1);
    Test.assertEqual(quest.type, KILL_ENEMIES);
    Test.assertEqual(quest.target, 10);
    Test.assertEqual(quest.progress, 3);
    Test.assertEqual(quest.reward_gold, 50);
    Test.assertEqual(quest.reward_exp, 25);
    Test.assertEqual(quest.description, "Slay 10 monsters.");
    Test.assert(!quest.completed);
    return true;
}

(:test)
function questInitializeWithNullDoesNotCrash(logger as Test.Logger) as Boolean {
    var quest = new Quest(null);
    Test.assertEqual(quest.id, 0);
    return true;
}

(:test)
function questAddProgressIncreasesProgress(logger as Test.Logger) as Boolean {
    var quest = new Quest({
        :id => 1, :type => KILL_ENEMIES, :target => 10, :progress => 0,
        :reward_gold => 0, :reward_exp => 0, :description => "", :completed => false
    });
    quest.addProgress(3);
    Test.assertEqual(quest.progress, 3);
    Test.assert(!quest.completed);
    return true;
}

(:test)
function questAddProgressClampsToTarget(logger as Test.Logger) as Boolean {
    var quest = new Quest({
        :id => 1, :type => KILL_ENEMIES, :target => 5, :progress => 0,
        :reward_gold => 0, :reward_exp => 0, :description => "", :completed => false
    });
    quest.addProgress(10);
    Test.assertEqual(quest.progress, 5);
    Test.assert(quest.completed);
    return true;
}

(:test)
function questAddProgressAlreadyCompletedDoesNothing(logger as Test.Logger) as Boolean {
    var quest = new Quest({
        :id => 1, :type => KILL_ENEMIES, :target => 5, :progress => 5,
        :reward_gold => 0, :reward_exp => 0, :description => "", :completed => true
    });
    quest.addProgress(5);
    Test.assertEqual(quest.progress, 5);
    return true;
}

(:test)
function questAddProgressZeroDoesNothing(logger as Test.Logger) as Boolean {
    var quest = new Quest({
        :id => 1, :type => KILL_ENEMIES, :target => 10, :progress => 3,
        :reward_gold => 0, :reward_exp => 0, :description => "", :completed => false
    });
    quest.addProgress(0);
    Test.assertEqual(quest.progress, 3);
    return true;
}

(:test)
function questGetTitleKillEnemies(logger as Test.Logger) as Boolean {
    var quest = new Quest({
        :id => 1, :type => KILL_ENEMIES, :target => 10, :progress => 0,
        :reward_gold => 0, :reward_exp => 0, :description => "", :completed => false
    });
    Test.assertEqual(quest.getTitle(), "Hunt Monsters");
    return true;
}

(:test)
function questGetTitleDealDamage(logger as Test.Logger) as Boolean {
    var quest = new Quest({
        :id => 1, :type => DEAL_DAMAGE, :target => 100, :progress => 0,
        :reward_gold => 0, :reward_exp => 0, :description => "", :completed => false
    });
    Test.assertEqual(quest.getTitle(), "Deal Damage");
    return true;
}

(:test)
function questGetTitleTakeDamage(logger as Test.Logger) as Boolean {
    var quest = new Quest({
        :id => 1, :type => TAKE_DAMAGE, :target => 50, :progress => 0,
        :reward_gold => 0, :reward_exp => 0, :description => "", :completed => false
    });
    Test.assertEqual(quest.getTitle(), "Endure Damage");
    return true;
}

(:test)
function questGetProgressLabelKillEnemies(logger as Test.Logger) as Boolean {
    var quest = new Quest({
        :id => 1, :type => KILL_ENEMIES, :target => 10, :progress => 3,
        :reward_gold => 0, :reward_exp => 0, :description => "", :completed => false
    });
    quest.getProgressLabel();
    return true;
}

(:test)
function questGetRewardLabel(logger as Test.Logger) as Boolean {
    var quest = new Quest({
        :id => 1, :type => KILL_ENEMIES, :target => 10, :progress => 0,
        :reward_gold => 50, :reward_exp => 25, :description => "", :completed => false
    });
    quest.getRewardLabel();
    return true;
}

(:test)
function questSaveAndLoad(logger as Test.Logger) as Boolean {
    var quest = new Quest({
        :id => 3, :type => DEAL_DAMAGE, :target => 500, :progress => 200,
        :reward_gold => 100, :reward_exp => 75, :description => "Deal 500 damage.", :completed => false
    });
    var saved = quest.save();
    Test.assertEqual(saved["id"], 3);
    Test.assertEqual(saved["type"], DEAL_DAMAGE);
    Test.assertEqual(saved["target"], 500);
    Test.assertEqual(saved["progress"], 200);
    Test.assertEqual(saved["reward_gold"], 100);
    Test.assertEqual(saved["reward_exp"], 75);

    var loaded = Quest.load(saved);
    Test.assertEqual(loaded.id, 3);
    Test.assertEqual(loaded.type, DEAL_DAMAGE);
    Test.assertEqual(loaded.target, 500);
    Test.assertEqual(loaded.progress, 200);
    Test.assertEqual(loaded.reward_gold, 100);
    Test.assertEqual(loaded.reward_exp, 75);
    Test.assert(!loaded.completed);
    return true;
}

(:test)
function questsBuildDescriptionKillEnemies(logger as Test.Logger) as Boolean {
    var desc = Quests.buildDescription(KILL_ENEMIES, 10);
    Test.assert(desc.length() > 0);
    return true;
}

(:test)
function questsBuildDescriptionDealDamage(logger as Test.Logger) as Boolean {
    var desc = Quests.buildDescription(DEAL_DAMAGE, 500);
    Test.assert(desc.length() > 0);
    return true;
}

(:test)
function questsBuildDescriptionTakeDamage(logger as Test.Logger) as Boolean {
    var desc = Quests.buildDescription(TAKE_DAMAGE, 100);
    Test.assert(desc.length() > 0);
    return true;
}

(:test)
function questsBuildDescriptionRunMinutes(logger as Test.Logger) as Boolean {
    var desc = Quests.buildDescription(RUN_MINUTES, 30);
    Test.assert(desc.length() > 0);
    return true;
}

(:test)
function questsBuildDescriptionWalkStairs(logger as Test.Logger) as Boolean {
    var desc = Quests.buildDescription(WALK_STAIRS, 50);
    Test.assert(desc.length() > 0);
    return true;
}

(:test)
function questsBuildDescriptionBikeDistance(logger as Test.Logger) as Boolean {
    var desc = Quests.buildDescription(BIKE_DISTANCE, 10);
    Test.assert(desc.length() > 0);
    return true;
}

(:test)
function questsBuildDescriptionWalkSteps(logger as Test.Logger) as Boolean {
    var desc = Quests.buildDescription(WALK_STEPS, 1000);
    Test.assert(desc.length() > 0);
    return true;
}

(:test)
function questsBuildTargetForTypeReturnsPositive(logger as Test.Logger) as Boolean {
    var types = [KILL_ENEMIES, DEAL_DAMAGE, TAKE_DAMAGE, RUN_MINUTES, WALK_STAIRS, BIKE_DISTANCE, WALK_STEPS];
    for (var i = 0; i < types.size(); i++) {
        var target = Quests.buildTargetForType(types[i], 5);
        Test.assert(target > 0);
    }
    return true;
}

(:test)
function questsBuildRewardsReturnsPositive(logger as Test.Logger) as Boolean {
    var rewards = Quests.buildRewards(10, 5, KILL_ENEMIES);
    Test.assert(rewards[0] > 0);
    Test.assert(rewards[1] > 0);
    return true;
}

(:test)
function questsBuildRewardsScaleWithDepth(logger as Test.Logger) as Boolean {
    var rewardsLow = Quests.buildRewards(10, 1, KILL_ENEMIES);
    var rewardsHigh = Quests.buildRewards(10, 10, KILL_ENEMIES);
    Test.assert(rewardsHigh[0] >= rewardsLow[0]);
    Test.assert(rewardsHigh[1] >= rewardsLow[1]);
    return true;
}

(:test)
function questsGetTypeRewardModifierKillEnemies(logger as Test.Logger) as Boolean {
    var mod = Quests.getTypeRewardModifier(KILL_ENEMIES);
    Test.assert(mod > 0);
    return true;
}

(:test)
function questsGetTypeRewardModifierDealDamage(logger as Test.Logger) as Boolean {
    var mod = Quests.getTypeRewardModifier(DEAL_DAMAGE);
    Test.assert(mod > 0);
    return true;
}

(:test)
function questsGetRandomTypeReturnsValidType(logger as Test.Logger) as Boolean {
    for (var i = 0; i < 20; i++) {
        var qt = Quests.getRandomType();
        Test.assert(qt == KILL_ENEMIES || qt == DEAL_DAMAGE || qt == TAKE_DAMAGE ||
            qt == RUN_MINUTES || qt == WALK_STAIRS || qt == BIKE_DISTANCE || qt == WALK_STEPS);
    }
    return true;
}

(:test)
function questsInitClearsState(logger as Test.Logger) as Boolean {
    Quests.init();
    Test.assertEqual(Quests.active_quests.size(), 0);
    Test.assertEqual(Quests.next_id, 1);
    return true;
}

(:test)
function questsAcceptQuestAddsToActive(logger as Test.Logger) as Boolean {
    Quests.init();
    var quest = new Quest({
        :id => 0, :type => KILL_ENEMIES, :target => 5, :progress => 0,
        :reward_gold => 10, :reward_exp => 5, :description => "Kill 5", :completed => false
    });
    var accepted = Quests.acceptQuest(quest);
    Test.assert(accepted != null);
    Test.assertEqual(Quests.active_quests.size(), 1);
    Test.assertEqual(accepted.id, 1);
    return true;
}

(:test)
function questsAcceptQuestReturnsNullWhenFull(logger as Test.Logger) as Boolean {
    Quests.init();
    for (var i = 0; i < Quests.MAX_ACTIVE; i++) {
        Quests.acceptQuest(new Quest({
            :id => 0, :type => KILL_ENEMIES, :target => 5, :progress => 0,
            :reward_gold => 0, :reward_exp => 0, :description => "", :completed => false
        }));
    }
    var result = Quests.acceptQuest(new Quest({
        :id => 0, :type => KILL_ENEMIES, :target => 5, :progress => 0,
        :reward_gold => 0, :reward_exp => 0, :description => "", :completed => false
    }));
    Test.assert(result == null);
    Test.assertEqual(Quests.active_quests.size(), Quests.MAX_ACTIVE);
    return true;
}

(:test)
function questsAcceptNullQuestReturnsNull(logger as Test.Logger) as Boolean {
    Quests.init();
    var result = Quests.acceptQuest(null);
    Test.assert(result == null);
    return true;
}

(:test)
function questsHasCompletedQuestsFalseWhenEmpty(logger as Test.Logger) as Boolean {
    Quests.init();
    Test.assert(!Quests.hasCompletedQuests());
    return true;
}

(:test)
function questsSaveAndLoad(logger as Test.Logger) as Boolean {
    Quests.init();
    Quests.acceptQuest(new Quest({
        :id => 0, :type => KILL_ENEMIES, :target => 5, :progress => 2,
        :reward_gold => 10, :reward_exp => 5, :description => "Kill 5", :completed => false
    }));
    var saved = Quests.save();
    Test.assert(saved["active"] != null);

    Quests.init();
    Test.assertEqual(Quests.active_quests.size(), 0);
    Quests.load(saved);
    Test.assertEqual(Quests.active_quests.size(), 1);
    return true;
}

(:test)
function questsLoadNullDoesNotCrash(logger as Test.Logger) as Boolean {
    Quests.init();
    Quests.load(null);
    Test.assertEqual(Quests.active_quests.size(), 0);
    return true;
}

(:test)
function questsCreateRandomQuestReturnsNonNull(logger as Test.Logger) as Boolean {
    Quests.init();
    var quest = Quests.createRandomQuest(5);
    Test.assert(quest != null);
    Test.assert(quest.target > 0);
    return true;
}

(:test)
function questsBuildQuestChoicesReturnsCorrectAmount(logger as Test.Logger) as Boolean {
    Quests.init();
    var choices = Quests.buildQuestChoices(5, 3);
    Test.assertEqual(choices.size(), 3);
    return true;
}
