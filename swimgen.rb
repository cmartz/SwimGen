

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

  warmDown = Array.new(20, $strokes[:free])

  set = {:warmup => warmup, :main => mainSet, :cooldown => warmDown}
  return set
end

def PrintSet(set)
  puts "Warm Up: "
  set[:warmup].each do |warmupSet|
    #puts "\t" + (subset.size * 25).to_s + "yds:"
    puts "\t" + warmupSet.size.to_s + " * "
    warmupSet.each do |subset|
    end
  end

  puts "Main Set: "
  set[:main].each do |subset|
    #puts "A set!"
  end

  puts "Cool Down: "
  set[:cooldown].each do |subset|
    #puts "A set!"
  end
end

set = QuickSet()

PrintSet(set)

puts Random.rand(10)
