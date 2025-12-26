import Toybox.Lang;
import Toybox.Math;
import Toybox.System;

// Tracks dungeon quests that measure player actions.
enum QuestType {
    KILL_ENEMIES,
    DEAL_DAMAGE,
    TAKE_DAMAGE,
    RUN_MINUTES,
    WALK_STAIRS,
    BIKE_DISTANCE,
    WALK_STEPS,
}

class Quest {
    var id as Number = 0;
    var type as QuestType = KILL_ENEMIES;
    var target as Number = 0;
    var progress as Number = 0;
    var reward_gold as Number = 0;
    var reward_exp as Number = 0;
    var description as String = "";
    var completed as Boolean = false;

    function initialize(options as Dictionary?) {
        if (options == null) {
            return;
        }
        id = options[:id];
        type = options[:type];
        target = options[:target];
        progress = MathUtil.clamp(options[:progress], 0, target);
        reward_gold = options[:reward_gold];
        reward_exp = options[:reward_exp];
        description = options[:description];
        completed = options[:completed];
    }

    function addProgress(amount as Number) as Void {
        if (completed) {
            return;
        }
        progress = MathUtil.clamp(progress + amount, 0, target);
        if (progress >= target) {
            progress = target;
            completed = true;
        }
    }

    function getTitle() as String {
        switch (type) {
            case KILL_ENEMIES:
                return "Hunt Monsters";
            case DEAL_DAMAGE:
                return "Deal Damage";
            case TAKE_DAMAGE:
                return "Endure Damage";
        }
        return "Quest";
    }

    function getProgressLabel() as String {
        var formatted_target = target.format("%.0f");
        var formatted_progress = progress.format("%.0f");

        switch (type) {
            case DEAL_DAMAGE:
            case TAKE_DAMAGE:
            case BIKE_DISTANCE:
                formatted_target = target.format("%.2f");
                formatted_progress = progress.format("%.2f");
                break;
            case RUN_MINUTES:
                formatted_target = target.format("%.0f") + " min";
                formatted_progress = progress.format("%.0f") + " min";
                return formatted_progress + "/" + formatted_target;
            case WALK_STAIRS:
                formatted_target = target.format("%.0f") + " stairs";
                formatted_progress = progress.format("%.0f") + " stairs";
                return formatted_progress + "/" + formatted_target;
            case WALK_STEPS:
                formatted_target = target.format("%.0f") + " steps";
                formatted_progress = progress.format("%.0f") + " steps";
                return formatted_progress + "/" + formatted_target;
            case KILL_ENEMIES:
                break;
        }
        return formatted_progress + "/" + formatted_target;
    }

    function getRewardLabel() as String {
        return reward_gold.format("%.0f")  + "g, " + reward_exp.format("%.0f") + "xp";
    }

    function save() as Dictionary {
        return {
            "id" => id,
            "type" => type,
            "target" => target,
            "progress" => progress,
            "reward_gold" => reward_gold,
            "reward_exp" => reward_exp,
            "description" => description,
            "completed" => completed
        };
    }

    static function load(data as Dictionary) as Quest {
        var quest = new Quest({
            :id => data["id"],
            :type => data["type"],
            :target => data["target"],
            :progress => data["progress"],
            :reward_gold => data["reward_gold"],
            :reward_exp => data["reward_exp"],
            :description => data["description"],
            :completed => data["completed"]
        });
        return quest;
    }
}

module Quests {
    const MAX_ACTIVE as Number = 3;

    var active_quests as Array<Quest> = new Array<Quest>[MAX_ACTIVE];
    var next_id as Number = 1;

    function init() as Void {
        active_quests = [];
        next_id = 1;
    }

    function save() as Dictionary {
        var serialized = new Array<Dictionary>[active_quests.size()];
        for (var i = 0; i < active_quests.size(); i++) {
            serialized[i] = active_quests[i].save();
        }
        return {
            "active" => serialized,
            "next_id" => next_id
        };
    }

    function load(data as Dictionary?) as Void {
        init();
        if (data == null) {
            return;
        }
        var stored = data["active"] as Array<Dictionary>?;
        if (stored != null) {
            for (var i = 0; i < stored.size(); i++) {
                active_quests.add(Quest.load(stored[i]));
            }
        }
        if (data["next_id"] != null) {
            next_id = data["next_id"] as Number;
        } else {
            next_id = active_quests.size() + 1;
        }
    }

    function getActiveQuests() as Array<Quest> {
        return active_quests;
    }

    function hasCompletedQuests() as Boolean {
        for (var i = 0; i < active_quests.size(); i++) {
            if (active_quests[i].completed) {
                return true;
            }
        }
        return false;
    }

    function addRandomQuest(depth as Number) as Quest? {
        var quest = createRandomQuest(depth);
        return acceptQuest(quest);
    }

    function acceptQuest(quest as Quest?) as Quest? {
        if (quest == null) {
            return null;
        }
        if (active_quests.size() >= MAX_ACTIVE) {
            return null;
        }
        quest.id = next_id;
        next_id += 1;
        active_quests.add(quest);
        return quest;
    }

    function buildQuestChoices(depth as Number, amount as Number) as Array<Quest> {
        var choices = [] as Array<Quest>;
        for (var i = 0; i < amount; i++) {
            var quest = createRandomQuest(depth);
            if (quest != null) {
                choices.add(quest);
            }
        }
        return choices;
    }

    function createRandomQuest(depth as Number) as Quest? {
        var quest_type = getRandomType();
        var quest_target = buildTargetForType(quest_type, depth);
        var rewards = buildRewards(quest_target, depth);
        return createQuestInstance(quest_type, quest_target, rewards);
    }

    function createQuestInstance(quest_type as QuestType, quest_target as Number, rewards as [Number, Number]) as Quest {
        return new Quest({
            :id => 0,
            :type => quest_type,
            :target => quest_target,
            :progress => 0,
            :reward_gold => rewards[0],
            :reward_exp => rewards[1],
            :description => buildDescription(quest_type, quest_target),
            :completed => false
        });
    }

    function buildDescription(type as QuestType, target as Number) as String {
        switch (type) {
            case KILL_ENEMIES:
                return "Slay " + target.format("%.0f") + " monsters.";
            case DEAL_DAMAGE:
                return "Deal " + target.format("%.2f") + " total damage.";
            case TAKE_DAMAGE:
                return "Take " + target.format("%.2f") + " damage and survive.";
            case RUN_MINUTES:
                return "Run for " + target.format("%.0f") + " minutes.";
            case WALK_STAIRS:
                return "Climb " + target.format("%.0f") + " stairs.";
            case BIKE_DISTANCE:
                return "Bike " + target.format("%.2f") + " km.";
            case WALK_STEPS:
                return "Walk " + target.format("%.0f") + " steps.";
        }
        return "Complete the task.";
    }

    function getRandomType() as QuestType {
        var roll = MathUtil.random(0, 99);
        if (roll < 40) {
            return KILL_ENEMIES;
        } else if (roll < 70) {
            return DEAL_DAMAGE;
        } else if (roll < 80) {
            return RUN_MINUTES;
        } else if (roll < 87) {
            return WALK_STAIRS;
        } else if (roll < 93) {
            return BIKE_DISTANCE;
        }
        return WALK_STEPS;
    }

    function buildTargetForType(type as QuestType, depth as Number) as Number {
        var depth_factor = MathUtil.clamp(Math.floor(Math.sqrt(MathUtil.max(1, depth + 1))), 1, 12);
        switch (type) {
            case KILL_ENEMIES:
                return MathUtil.clamp(3 + depth_factor + MathUtil.random(0, 3), 3, 20);
            case DEAL_DAMAGE:
                return MathUtil.clamp(20 + depth_factor * 10 + MathUtil.random(0, 25), 25, 200);
            case TAKE_DAMAGE:
                return MathUtil.clamp(10 + depth_factor * 8 + MathUtil.random(0, 20), 15, 160);
            case RUN_MINUTES:
                return MathUtil.clamp(5 + depth_factor + MathUtil.random(0, 10), 5, 90);
            case WALK_STAIRS:
                return MathUtil.clamp(20 + depth_factor * 5 + MathUtil.random(0, 20), 20, 250);
            case BIKE_DISTANCE:
                return MathUtil.clamp(1 + depth_factor * 0.5 + MathUtil.random(0, 5), 1, 30);
            case WALK_STEPS:
                return MathUtil.clamp(500 + depth_factor * 200 + MathUtil.random(0, 800), 500, 10000);
        }
        return 10;
    }

    function buildRewards(target as Number, depth as Number) as [Number, Number] {
        var depth_bonus = MathUtil.max(1, depth + 1);
        var gold = Math.floor(MathUtil.max(5, target * 2 / 3 + depth_bonus * 2));
        var exp = Math.floor(MathUtil.max(5, target + depth_bonus * 3));
        return [gold, exp];
    }

    function trackKill(enemy as Enemy) as Void {
        addProgress(KILL_ENEMIES, 1);
    }

    function trackDamageDealt(amount as Number) as Void {
        if (amount <= 0) {
            return;
        }
        addProgress(DEAL_DAMAGE, amount);
    }

    function trackDamageTaken(amount as Number) as Void {
        if (amount <= 0) {
            return;
        }
        addProgress(TAKE_DAMAGE, amount);
    }

    function trackRunMinutes(minutes as Number) as Void {
        if (minutes <= 0) {
            return;
        }
        addProgress(RUN_MINUTES, minutes);
    }

    function trackWalkStairs(stairs as Number) as Void {
        if (stairs <= 0) {
            return;
        }
        addProgress(WALK_STAIRS, stairs);
    }

    function trackBikeDistance(distance_km as Number) as Void {
        if (distance_km <= 0) {
            return;
        }
        addProgress(BIKE_DISTANCE, distance_km);
    }

    function trackWalkSteps(steps as Number) as Void {
        if (steps <= 0) {
            return;
        }
        addProgress(WALK_STEPS, steps);
    }

    function addProgress(type as QuestType, amount as Number) as Void {
        for (var i = 0; i < active_quests.size(); i++) {
            var quest = active_quests[i];
            if (quest.type == type) {
                quest.addProgress(amount);
            }
        }
    }

    function claimCompleted(player as Player) as Dictionary<Symbol, Number> {
        var claimed = 0;
        var total_gold = 0;
        var total_exp = 0;
        var remaining = [] as Array<Quest>;
        for (var i = 0; i < active_quests.size(); i++) {
            var quest = active_quests[i];
            if (quest.completed) {
                claimed += 1;
                total_gold += quest.reward_gold;
                total_exp += quest.reward_exp;
            } else {
                remaining.add(quest);
            }
        }
        if (claimed > 0) {
            player.doGoldDelta(total_gold);
            player.onGainExperience(total_exp);
        }
        active_quests = remaining;
        return {
            :claimed => claimed,
            :gold => total_gold,
            :exp => total_exp
        };
    }
}
