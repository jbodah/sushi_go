CARDS = [
  :nigiri_3,
  :nigiri_2,
  :nigiri_1,
  :wasabi,
  :tempura,
  :sashimi,
  :dumpling,

  :maki_major,
  :maki_major_tied,
  :maki_minor,
  :maki_minor_tied,

  # :pudding_majority,
]

@cache_wasabi_nigiris = {}
def score_wasabi_nigiris(set)
  @cache_wasabi_nigiris[set.hash] ||=
    begin
      total = 0
      while set.include?(:wasabi)
        set.delete_at(set.index(:wasabi))
        case
        when set.include?(:nigiri_3)
          set.delete_at(set.index(:nigiri_3))
          total += 9
        when set.include?(:nigiri_2)
          set.delete_at(set.index(:nigiri_2))
          total += 6
        when set.include?(:nigiri_1)
          set.delete_at(set.index(:nigiri_1))
          total += 3
        end
      end
      total += 3 * set.count { |card| card == :nigiri_3 }
      total += 2 * set.count { |card| card == :nigiri_2 }
      total += 1 * set.count { |card| card == :nigiri_1 }
      total
    end
end

def score_tempuras(tempuras)
  (tempuras / 2) * 5
end

def score_sashimi(sashimi)
  (sashimi / 3) * 10
end

def score_dumplings(dumplings)
  case dumplings
  when 0 then 0
  when 1 then 1
  when 2 then 3
  when 3 then 6
  when 4 then 10
  else 15
  end
end

@puddings = {
  pudding_majority: 6,
  none: 0,
}
def score_puddings(puddings)
  @puddings[puddings]
end

@maki = {
  :maki_major => 6,
  :maki_major_tied => 3,
  :maki_minor => 3,
  :maki_minor_tied => 1.5,
  :none => 0
}
def score_maki(maki)
  @maki[maki]
end

def score(set)
  wasabi_nigiris = []
  tempuras = 0
  maki = :none
  puddings = :none
  sashimi = 0
  dumplings = 0

  set.each do |card|
    case card
    when :wasabi, :nigiri_3, :nigiri_2, :nigiri_1
      wasabi_nigiris << card
    when :tempura
      tempuras += 1
    when :maki_major, :maki_major_tied, :maki_minor, :maki_minor_tied
      maki = card
    when :pudding_majority
      puddings = :pudding_majority
    when :dumpling
      dumplings += 1
    when :sashimi
      sashimi += 1
    end
  end

  total = 0
  total += score_wasabi_nigiris(wasabi_nigiris)
  total += score_tempuras(tempuras)
  total += score_maki(maki)
  total += score_puddings(puddings)
  total += score_sashimi(sashimi)
  total += score_dumplings(dumplings)
  total
end

out = File.open('values.out', 'w')

max=8
(1..max).each do |set_size|
  seen = {}
  sets = []
  (0..(CARDS.size ** set_size - 1)).each do |encoding|
    digits = encoding.digits(CARDS.size)
    if digits.size < set_size
      suffix = [0] * (set_size - digits.size)
      digits += suffix
    end
    # bucket sort
    buckets = Array.new(CARDS.size) { 0 }
    digits.each do |digit|
      buckets[digit] += 1
    end
    next if seen[buckets.hash] == true
    seen[buckets.hash] = true

    set = buckets.zip(CARDS).reduce([]) { |acc, (count, card)| acc + [card]*count }

    n = 0
    n += 1 if set.include?(:maki_major)
    n += 1 if set.include?(:maki_major_tied)
    n += 1 if set.include?(:maki_minor)
    n += 1 if set.include?(:maki_minor_tied)
    next if n > 1

    sets << set
  end

  puts "SIZE = #{set_size}"
  puts sets.size
  sets_by_score = sets.map { |set| [score(set), set] }.sort_by { |score, _| -score }
  puts "SIZE = #{set_size} (done)"
  out.puts "SIZE = #{set_size}"
  sets_by_score.each do |score, set|
    out.puts "* #{score} #{set.sort.inspect}"
  end
  out.puts
end

out.close
