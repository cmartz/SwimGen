

$strokes = {:fly => 0, :back => 1, :breast => 2, :free => 3}
$strokes_lookup = $strokes.invert


def GenSet(lapsPerRep, maxLaps, lapSet)
  numReps = (maxLaps / lapsPerRep).floor

  set = lapSet.repeated_permutation(lapsPerRep).to_a
  return set

  #To-Do: implement total distance restrictions
end

def QuickSet
  fiveHundredFree = Array.new(20, $strokes[:free])
  basicWarmup = [fiveHundredFree]
  techWarmup = GenSet(3, 500, [$strokes[:free], $strokes[:back]])
  warmup = [basicWarmup, techWarmup]

  hundredFree = Array.new(4, $strokes[:free])
  mainSet = Array.new(10, hundredFree)
  main = [mainSet]

  warmDownSet = [fiveHundredFree]
  coolDown = [warmDownSet]

  set = {:warmup => warmup, :main => main, :cooldown => coolDown}
  return set
end

def SetToString(set)
  setString = ""
  last_lap = nil
  lap_count = 0
  set.each do |lap|
    if lap == last_lap or last_lap == nil
      lap_count += 1
    else
      setString += (lap_count * 25).to_s + " " + $strokes_lookup[last_lap].to_s
      lap_count = 1
    end
    last_lap = lap
  end
  setString += (lap_count * 25).to_s + " " + $strokes_lookup[last_lap].to_s
  return setString
end

def PrintSet(set)
  puts "Warm Up: "
  set[:warmup].each do |warmupSet|
    #puts "\t" + (subset.size * 25).to_s + "yds:"
    puts "\t" + warmupSet.size.to_s + " * "
    warmupSet.each do |subset|
      puts "\t\t" + (subset.size * 25).to_s + ": "
      last_lap = nil
      lap_count = 0
      subset.each do |lap|
        if lap == last_lap or last_lap == nil
          lap_count += 1
        else
          puts "\t\t\t" + (lap_count * 25).to_s + " " + $strokes_lookup[last_lap].to_s
          count = 1
        end
        last_lap = lap
      end
      puts "\t\t\t" + (lap_count * 25).to_s + " " + $strokes_lookup[last_lap].to_s
    end
  end

  puts "Main Set: "
  set[:main].each do |mainSet|
    mainSet.each do |subset|
      puts "\t\t" + (subset.size * 25).to_s + ": " + SetToString(subset)
    end
  end

  puts "Cool Down: "
  set[:cooldown].each do |cooldownSet|
    cooldownSet.each do |subset|
      puts "\t\t" + (subset.size * 25).to_s + ": " + SetToString(subset)
    end
  end
end

set = QuickSet()

PrintSet(set)

puts Random.rand(10)
